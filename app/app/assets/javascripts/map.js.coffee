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
  ra_1 = Math.round((parseInt(params.ra_h_1) + parseInt(params.ra_m_1)/60.0) * 15)
  ra_2 = Math.round((parseInt(params.ra_h_2) + parseInt(params.ra_m_1)/60.0) * 15)
  center_ra = (ra_2 + ra_1) / 2
  ra_grid = parseInt(params.ra_grid) / 4

  dec_1 = parseInt(params.dec_deg_1)
  dec_2 = parseInt(params.dec_deg_2)
  center_dec = (dec_2 + dec_1) / 2
  center_dec = 1 if (center_dec < 1 and center_dec >= 0)
  center_dec = -1 if (center_dec > -1 and center_dec < 0)
  dec_grid = parseInt(params.dec_grid)

  star_max_mag = parseFloat(params.max_mag)
  star_min_rad = parseFloat(params.small_rad)
  star_scale = parseFloat(params.scale)

  map_width = 1870
  map_height = 1000
  map_title = params.title

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
  html.push(generate_ra_line deg) for deg in [ra_1..ra_2] by ra_grid

  html.push(generate_dec_line dec_1)
  html.push(generate_dec_line dec_2)
  html.push(generate_dec_line deg) for deg in [dec_1..dec_2] by dec_grid

  html.push(generate_dso dso) for dso in obj.dsos
  html.push(generate_hip_star star) for star in obj.hip_stars
  html.push(generate_tyc_star star) for star in obj.tyc_stars

  "<svg id='star_map' xmlns='http://www.w3.org/2000/svg' version='1.1'>" + html.join(" ") + "</svg>"
  
generate_frame = ->
  #border_rect = "<rect class='line' x='25' y='85' width='" + map_width.toString() + "' height='" + (map_height + 20).toString() + "' />"
  title = "<text class='title' x='50' y='75'>" + map_title + "</text>"
  mag = Math.round(star_max_mag)
  mags = []
  mags.push("<circle class ='star' cx='#{1005+i*25}' cy='60' r='#{star_min_rad + 6 - i * star_scale}' /><text class='label' x='#{1000+i*25}' y='40'>#{mag - (6 - i)}</text>") for i in [0..6]
  title + mags.join(" ")

generate_hip_star = (star) ->
  [x, y] = get_xy(star.ra_deg, star.dec_deg)
  r = star_min_rad + (star_max_mag - star.mag) * star_scale
  r = Math.round(r*100)/100
  "<circle class='white_star' cx='#{x}' cy='#{y}' r='#{r+0.5}' /> <circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"
  #"<circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"

generate_tyc_star = (star) ->
  [x, y] = get_xy(star.ra_deg, star.dec_deg)
  r = star_min_rad + (star_max_mag - star.mag) * star_scale
  r = Math.round(r*100)/100
  #"<circle class='white_star' cx='#{x}' cy='#{y}' r='#{r+0.5}' /> <circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"
  "<circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"

generate_dso = (dso) ->
  [x, y] = get_xy(dso.ra_deg, dso.dec_deg)
  switch dso.obj_type_id
    when 1
      #"<ellipse class='galaxy' cx='#{x}' cy='#{y}' rx='#{r}' ry = '#{r2}' transform='rotate(#{dso.pa})' />"
      r_maj = Math.max(5, Math.round(dso.size_maj * pix_per_min / 2.0, 1))
      r_min = Math.max(3, Math.round(dso.size_min * pix_per_min / 2.0, 1))
      "<ellipse class='galaxy' cx='#{x}' cy='#{y}' rx='#{r_maj}' ry = '#{r_min}' transform='rotate(#{dso.pa}, #{x}, #{y})' />"
    when 5
      r = 3
      "<circle class='open_cluster' cx='#{x}' cy='#{y}' r='#{r}' />"
    when 6
      r = 3
      "<circle class='globular_cluster' cx='#{x}' cy='#{y}' r='#{r}' /> <line class='line' x1='#{x-r}' y1='#{y}' x2='#{x+r}' y2='#{y}' /> <line class='line' x1='#{x}' y1='#{y-r}' x2='#{x}' y2='#{y+r}' />"
    when 2
      s = 6
      s2 = s/2
      "<rect class='bright_nebula' x='#{x-s2}' y='#{y-s2}' width='#{s}' height='#{s}' />"
    when 4
      r = 4
      r2 = r/2 # not sure why I had to create this; weird bug
      "<line class='line' x1='#{x-r}' y1='#{y}' x2='#{x+r}' y2='#{y}' /> <line class='line' x1='#{x}' y1='#{y-r}' x2='#{x}' y2='#{y+r}' /> <circle class='plan_nebula' cx='#{x}' cy='#{y}' r='#{r2}' />"

generate_dec_line = (deg) ->
  i = ra_1
  [fx, fy] = get_xy(ra_1, deg)
  [lx, ly] = get_xy(ra_2, deg)
  lines = while i <= ra_2
    [x, y] = get_xy(i, deg)
    i += 1
    "#{x},#{y}"
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
  min = Math.floor((ra - hours) * 60)
  ret = "#{hours}h"
  ret += "#{min}m" if min != 0
  ret


dec_to_label_text = (dec) ->
  deg = Math.floor(dec)
  sign = "" if deg == 0
  sign = "+" if deg > 0
  sign = "-" if deg < 0
  "#{sign}#{deg}"

