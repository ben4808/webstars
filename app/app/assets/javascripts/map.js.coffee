# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# globals
ra_1 = 0
ra_2 = 0
center_ra = 0
ra_grid = 0

dec_1 = 0
dec_2 = 0
center_dec = 0
dec_grid = 0

star_max_mag = 0
star_min_rad = 0
star_scale = 0

map_width = 0
map_height = 0
map_title = ""
map_text_size = 0

proper_names = false
var_labels = false
uncommon = false
bayer = false
flamsteed = false
gould = false
hip_labels = false
hip_mag = 0
hd_labels = false
hd_mag = 0
tyc_labels = false
tyc_mag = 0

pix_per_min = 0

# projection globals
n = 0
G = 0
p0 = 0
R = 1

# window so that the javascript can be called from the onclick handler on the generate button.
window.generate_map = (data_obj, div_id, params) ->
  update_globals(params)

  $(div_id).html("Loading...")
  $(div_id).html(generate_html(data_obj))
  #$(div_id).html(data)
  return

update_globals = (params) ->
  ra_1 = Math.round((parseInt(params.ra_h_1) + parseInt(params.ra_m_1)/60.0) * 150) / 10
  ra_2 = Math.round((parseInt(params.ra_h_2) + parseInt(params.ra_m_2)/60.0) * 150) / 10
  if(ra_1 > ra_2)
    center_ra = Math.round((ra_2 + ra_1 + 360) / 2.0 * 100) / 100
    center_ra -= 360 if center_ra > 360
  else
    center_ra = Math.round((ra_2 + ra_1) / 2.0 * 100) / 100
  ra_grid = parseInt(params.ra_grid) / 4

  dec_1 = parseInt(params.dec_deg_1)
  dec_2 = parseInt(params.dec_deg_2)
  [dec_2, dec_1] = [dec_1, dec_2] if dec_1 > dec_2
  center_dec = Math.round((dec_2 + dec_1) / 2.0 * 10) / 10
  center_dec = 1 if (center_dec < 1 and center_dec >= 0)
  center_dec = -1 if (center_dec > -1 and center_dec < 0)
  dec_grid = parseInt(params.dec_grid)

  star_max_mag = parseFloat(params.max_mag)
  star_min_rad = parseFloat(params.small_rad)
  star_scale = parseFloat(params.scale)

  map_width = 1870
  map_height = 1000
  map_title = params.title
  map_text_size = parseInt(params.text_size)

  proper_names = 'prop_names' of params
  uncommon = 'uncommon' of params
  var_labels = 'var_names' of params
  bayer = 'bayer_names' of params
  flamsteed = 'flam_names' of params
  gould = 'gould_names' of params
  hip_labels = 'hip' of params
  hip_mag = parseFloat(params.hip_mag) if !!params.hip_mag.replace(/^\s+|\s+$/g, "")
  hd_labels = 'hd' of params
  hd_mag = parseFloat(params.hd_mag) if !!params.hd_mag.replace(/^\s+|\s+$/g, "")
  tyc_labels = 'tyc' of params
  tyc_mag = parseFloat(params.tyc_mag) if !!params.tyc_mag.replace(/^\s+|\s+$/g, "")

  # conic equidistant projection, single standard parallel
  sp = deg_to_rad(center_dec)
  n = Math.sin(sp)
  G = Math.cos(sp) / n + sp
  p0 = (G - sp)

  # find extreme points for scaling
  [left, right, top, bottom] = find_extremes()
  ra_R = (map_width - 20) / (right - left)
  dec_R = (map_height - 20) / (bottom - top)
  R = Math.min(ra_R, dec_R)

  pix_per_min = (get_xy(center_ra, center_dec)[1] - get_xy(center_ra, center_dec+10)[1]) / 600.0
  pix_per_min = Math.round(pix_per_min*10) / 10

  return

find_extremes = ->
  R = 1
  ext = [get_xy(ra_1, dec_1), get_xy(ra_1, dec_2), get_xy(ra_2, dec_1), get_xy(ra_2, dec_2),
         get_xy(center_ra, dec_1), get_xy(center_ra, dec_2)]
  left = Math.min.apply(null, x for x in ext.map (e) -> e[0])
  right = Math.max.apply(null, x for x in ext.map (e) -> e[0])
  top = Math.min.apply(null, y for y in ext.map (e) -> e[1])
  bottom = Math.max.apply(null, y for y in ext.map (e) -> e[1])
  [left, right, top, bottom]

generate_html = (obj) ->
  html = []
  html.push(generate_frame()) 

  html.push(generate_ra_line ra_1)
  html.push(generate_ra_line ra_2)
  ra_lines = []
  if (ra_1 > ra_2)
    html.push(generate_ra_line deg) for deg in [ra_1...360] by ra_grid
    html.push(generate_ra_line deg) for deg in [0..ra_2] by ra_grid
  else
    html.push(generate_ra_line deg) for deg in [ra_1..ra_2] by ra_grid

  html.push(generate_dec_line dec_1)
  html.push(generate_dec_line dec_2)
  html.push(generate_dec_line deg) for deg in [dec_1..dec_2] by dec_grid

  html.push(generate_dso dso) for dso in obj.ngcic_dsos
  html.push(generate_dso dso) for dso in obj.other_dsos
  html.push(generate_star star) for star in obj.hip_stars
  html.push(generate_star star) for star in obj.tyc_stars
  html.push(generate_star star) for star in obj.ucac_stars

  "<svg id='star_map' xmlns='http://www.w3.org/2000/svg' version='1.1'>" + html.join(" ") + "</svg>"
  
generate_frame = ->
  title = "<text class='title' font-size='24' x='50' y='50'>" + map_title + "</text>"
  mag = Math.round(star_max_mag)
  mags = []
  mags.push("<circle class ='star' cx='#{1005+i*25}' cy='60' r='#{star_min_rad + 6 - i * star_scale}' /><text class='label' x='#{1000+i*25}' y='40'>#{mag - (6 - i)}</text>") for i in [0..6]
  title + mags.join(" ")

generate_star = (star) ->
  [x, y] = get_xy(star.ra_deg, star.dec_deg)
  r = star_min_rad + (star_max_mag - star.mag) * star_scale
  r = Math.round(r*100)/100
  label = star_label(star)
  ret = "<circle class='white_star' cx='#{x}' cy='#{y}' r='#{r+0.5}' /> <circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"
  ret += "<text class='label' font-size='#{map_text_size}' x='#{x+r}' y='#{y-r}'>#{label}</text>" if label != ""
  ret

generate_dso = (dso) ->
  [x, y] = get_xy(dso.ra_deg, dso.dec_deg)
  ret = ""
  r = 0
  switch dso.obj_type_id
    when 1
      r_maj = Math.max(5, Math.round(dso.size_maj * pix_per_min / 2.0, 1))
      r_min = Math.max(3, Math.round(dso.size_min * pix_per_min / 2.0, 1))
      r = r_maj
      r_min = r_maj if(dso.size_min == null)
      ret = "<ellipse class='galaxy' cx='#{x}' cy='#{y}' rx='#{r_maj}' ry = '#{r_min}' transform='rotate(#{dso.pa}, #{x}, #{y})' />"
    when 5
      r = Math.max(5, Math.round(dso.size_maj * pix_per_min / 2.0, 1))
      ret = "<circle class='open_cluster' cx='#{x}' cy='#{y}' r='#{r}' />"
    when 6
      r = Math.max(5, Math.round(dso.size_maj * pix_per_min / 2.0, 1))
      ret = "<circle class='globular_cluster' cx='#{x}' cy='#{y}' r='#{r}' /> <line class='line' x1='#{x-r}' y1='#{y}' x2='#{x+r}' y2='#{y}' /> <line class='line' x1='#{x}' y1='#{y-r}' x2='#{x}' y2='#{y+r}' />"
    when 2
      s = Math.max(5, Math.round(dso.size_maj * pix_per_min, 1))
      s2 = s/2
      r = s2
      ret = "<rect class='bright_nebula' x='#{x-s2}' y='#{y-s2}' width='#{s}' height='#{s}' />"
    when 3
      s = Math.max(5, Math.round(dso.size_maj * pix_per_min, 1))
      s2 = s/2
      r = s2
      ret = "<rect class='dark_nebula' x='#{x-s2}' y='#{y-s2}' width='#{s}' height='#{s}' />"
    when 4
      r = Math.max(7, Math.round(dso.size_maj * pix_per_min / 2.0, 1))
      r2 = r/2 # not sure why I had to create this; weird bug
      ret = "<line class='line' x1='#{x-r}' y1='#{y}' x2='#{x+r}' y2='#{y}' /> <line class='line' x1='#{x}' y1='#{y-r}' x2='#{x}' y2='#{y+r}' /> <circle class='plan_nebula' cx='#{x}' cy='#{y}' r='#{r2}' />"
    
  label = dso_label(dso)
  ret += "<text class='dso_label' font-size='#{map_text_size}'  x='#{x+r}' y='#{y-r}'>#{label}</text>" if label != ""
  ret

generate_dec_line = (deg) ->
  lines = []
  [fx, fy] = get_xy(ra_1, deg)
  [lx, ly] = get_xy(ra_2, deg)
  if ra_1 > ra_2
    i = ra_1
    [ax, ay] = get_xy(center_ra, deg)
    lines = while i <= 360
      [x, y] = get_xy(i, deg)
      i += 1
      "#{x},#{y}"
    lines.push "#{ax},#{ay}"
    i = 0
    lines2 = while i <= ra_2
      [x, y] = get_xy(i, deg)
      i += 1
      "#{x},#{y}"
    Array::push.apply lines, lines2
    lines.push "#{lx},#{ly}"

  else
    i = ra_1
    lines = while i <= ra_2
      [x, y] = get_xy(i, deg)
      i += 1
      "#{x},#{y}"
    lines.push "#{lx},#{ly}"
  all_lines = lines.join(" ")
  "<text class='label' x='#{lx-30}' y='#{ly}'>#{dec_to_label_text(deg)}</text><polyline class='line' points='#{all_lines}' /><text class='label' x='#{fx+5}' y='#{fy}'>#{dec_to_label_text(deg)}</text>"

generate_ra_line = (deg) ->
  i = dec_1
  [fx, fy] = get_xy(deg, dec_1)
  [lx, ly] = get_xy(deg, dec_2)
  lines = while i <= dec_2
    [x, y] = get_xy(deg, i)
    i += 1
    "#{x},#{y}"
  lines.push "#{lx},#{ly}"
  all_lines = lines.join(" ")
  "<text class='label' x='#{fx}' y='#{fy+15}'>#{ra_to_label_text(deg)}</text><polyline class='line' points='#{all_lines}' /><text class='label' x='#{lx}' y='#{ly-5}'>#{ra_to_label_text(deg)}</text>"

get_xy = (ra, dec) ->
  ra = deg_to_rad(ra)
  dec = deg_to_rad(dec)
  cra = deg_to_rad(center_ra)

  ra_diff = ra - cra
  ra_diff += (2*Math.PI) if ra_diff <= -Math.PI
  ra_diff -= (2*Math.PI) if ra_diff >= Math.PI

  th = n * ra_diff
  p = (G - dec)
  x = p * Math.sin(th)
  y = p0 - p * Math.cos(th)

  x = x * R * map_width + map_width / 2
  x = map_width - x
  x = Math.round(x*10)/10
  x = x + 20
  y = y * R * map_width + map_height / 2
  y = map_height - y
  y = Math.round(y*10)/10
  y = y + 95
  #y = y + 15 if center_dec > 0
  #y = y - 15 if center_dec < 0
  [x, y] 

deg_to_rad = (deg) ->
  deg * Math.PI / 180.0

ra_to_label_text = (ra) ->
  ra /= 15.0
  hours = Math.floor(ra)
  min = Math.round((ra - hours) * 60)
  ret = "#{hours}h"
  ret += "#{min}m" if min != 0
  ret

dec_to_label_text = (dec) ->
  deg = Math.floor(dec)
  sign = "" if deg == 0
  sign = "+" if deg > 0
  sign = "-" if deg < 0
  "#{sign}#{deg}"

star_label = (star) ->
  return "" if (not ('tyc1' of star) and not ('hip' of star))

  if 'tyc1' of star and tyc_labels and star.mag <= tyc_mag
    if(hd_labels and star.hd != null and star.mag <= hd_mag)
      return "HD #{star.hd}"
    else
      return "TYC #{star.tyc1} #{star.tyc2} #{star.tyc3}"
  else if 'tyc1' of star
    return ""

  label = ""
  if hd_labels and star.hd != null and star.mag <= hd_mag
    label = "HD #{star.hd}"
  if hip_labels and star.hip != null and star.mag <= hip_mag
    label = "HIP #{star.hip}"
  if gould and star.gould != null
    label = "#{star.gould}G."
  if flamsteed and star.flam != null
    label = "#{star.flam}"
  if bayer and star.bayer != null
    label = "#{star.bayer}"
  if var_labels and star.var_name != null
    label = "#{star.var_name}"
  if proper_names and star.name != null and (uncommon or star.is_common)
    label = "#{star.name}"
  label

dso_label = (dso) ->
  label = ""
  if 'ngc' of dso
    if dso.ic != null
      label = "IC #{dso.ic}"
    if dso.ngc != null
      label = "#{dso.ngc}"
    if dso.mess != null
      label = "M#{dso.mess}"
  else
    label = "#{dso.name}"
  label

window.generate_table = (obj, div_id) ->
  html = []
  html.push(generate_dso_row dso) for dso in obj.ngcic_dsos
  html.push(generate_dso_row dso) for dso in obj.other_dsos

  $(div_id).append(html.join(" "))

generate_dso_row = (dso) ->
  obj_types = ['', 'Gx', 'BN', 'DN', 'PN', 'OC', 'GC']

  ret = "<tr>"
  if 'ngc' of dso
    name = "NGC #{dso.ngc}" if dso.ngc != null
    name = "IC #{dso.ic}" if dso.ic != null
    name = "M#{dso.mess}" if dso.mess != null
    ret += "<td>#{name}</td>"
    ret += "<td>#{obj_types[dso.obj_type_id]}</td>"
    ra_h = Math.floor(dso.ra_deg / 15.0)
    ra_m = Math.round((dso.ra_deg - ra_h*15) * 4 * 10) / 10
    ret += "<td>#{ra_h}h #{ra_m}m</td>"
    dec_deg = Math.floor(dso.dec_deg)
    dec_m = Math.round((dso.dec_deg - dec_deg) * 60 * 10) / 10
    dec_sign = ''
    dec_sign = '+' if dec_deg >= 0
    ret += "<td>#{dec_sign}#{dec_deg} #{dec_m}m</td>"
    size = ''
    size = "#{dso.size_maj}" if dso.size_maj != null
    size += "x#{dso.size_min}" if dso.size_min != null
    ret += "<td>#{size}</td>"
    mag = ''
    mag = "#{dso.mag}" if dso.mag != null
    ret += "<td>#{mag}</td>"
    name = ''
    name = "#{dso.name}" if dso.name != null
    ret += "<td>#{name}</td>"
    notes = ''
    notes = "#{dso.description}" if dso.description != null
    ret += "<td>#{notes}</td>"
  else
    ret += "<td>#{dso.name}</td>"
    ret += "<td>#{obj_types[dso.obj_type_id]}</td>"
    ra_h = Math.floor(dso.ra_deg / 15.0)
    ra_m = Math.round((dso.ra_deg - ra_h*15) * 4 * 10) / 10
    ret += "<td>#{ra_h}h #{ra_m}m</td>"
    dec_deg = Math.floor(dso.dec_deg)
    dec_m = Math.round((dso.dec_deg - dec_deg) * 60 * 10) / 10
    dec_sign = ''
    dec_sign = '+' if dec_deg >= 0
    ret += "<td>#{dec_sign}#{dec_deg} #{dec_m}m</td>"
    size = ''
    size = "#{dso.size_maj}" if dso.size_maj != null
    size += "x#{dso.size_min}" if dso.size_min != null
    ret += "<td>#{size}</td>"
    mag = ''
    mag = "#{dso.mag}" if dso.mag != null
    ret += "<td>#{mag}</td>"
    ret += "<td></td>"
    ret += "<td></td>"
  ret += "</tr>"
  ret
