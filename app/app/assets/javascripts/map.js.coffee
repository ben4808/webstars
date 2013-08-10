# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# globals
form_data = {}

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

# projection globals
n = 0
G = 0
p0 = 0
R = 1

# window so that the javascript can be called from the onclick handler on the generate button.
window.generate_map = (data_obj, div_id, params) ->
  update_globals()

  $('#map_div').html("Loading...")
  form_post_data = $('#options_form').serialize()
  output = "Error Loading Data."
  $.post("/map", form_post_data, (data, status) ->
    output = generate_html(data) if status is "success"
    $('#map_div').html(output)
    #$('#map_div').html(data)
    return
  , 'json')
  return

update_globals = ->
  form_data = {}
  data = $('#options_form').serializeArray()
  form_data[elem.name] = elem.value for elem in data 

  ra_1 = Math.round((parseInt(form_data.ra_h_1) + parseInt(form_data.ra_m_1)/60.0) * 15)
  ra_2 = Math.round((parseInt(form_data.ra_h_2) + parseInt(form_data.ra_m_1)/60.0) * 15)
  center_ra = (ra_2 + ra_1) / 2
  ra_grid = parseInt(form_data.ra_grid) / 4

  dec_1 = parseInt(form_data.dec_deg_1)
  dec_2 = parseInt(form_data.dec_deg_2)
  center_dec = (dec_2 + dec_1) / 2
  center_dec = 1 if (center_dec < 1 and center_dec >= 0)
  center_dec = -1 if (center_dec > -1 and center_dec < 0)
  dec_grid = parseInt(form_data.dec_grid)

  star_max_mag = parseFloat(form_data.max_mag)
  star_min_rad = parseFloat(form_data.small_rad)
  star_scale = parseFloat(form_data.scale)

  map_width = 960
  map_height = 540

  # conic equidistant projection, single standard parallel
  sp = deg_to_rad(center_dec)
  n = Math.sin(sp)
  G = Math.cos(sp) / n + sp
  #p0 = R * (G - sp)
  p0 = (G - sp)

  # find extreme points for scaling
  [left, right, top, bottom] = find_extremes()
  ra_R = (map_width - 20) / (right - left)
  dec_R = (map_height - 20) / (bottom - top)
  R = Math.min(ra_R, dec_R)

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

generate_html = (data) ->
  obj = $.parseJSON(data)
  html = [] 
  html.push(generate_ra_line deg) for deg in [ra_1..ra_2] by ra_grid
  html.push(generate_dec_line deg) for deg in [dec_1..dec_2] by dec_grid

  html.push(generate_dso dso) for dso in obj.dsos
  html.push(generate_hip_star star) for star in obj.hip_stars
  html.push(generate_tyc_star star) for star in obj.tyc_stars

  "<svg class='starmap' xmlns='http://www.w3.org/2000/svg' version='1.1'>" + html.join(" ") + "</svg>"
  
generate_hip_star = (star) ->
  [x, y] = get_xy(star.ra_deg, star.dec_deg)
  r = star_min_rad + (star_max_mag - star.mag) * star_scale
  r = Math.round(r*100)/100
  #"<circle class='white_star' cx='#{x}' cy='#{y}' r='#{r+0.5}' /> <circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"
  "<circle class='star' cx='#{x}' cy='#{y}' r='#{r}' />"

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
      r = 4
      r2 = r/2
      a = r * 2 if dso.mess is '108'
      #"<ellipse class='galaxy' cx='#{x}' cy='#{y}' rx='#{r}' ry = '#{r2}' transform='rotate(#{dso.pa})' />"
      "<ellipse class='galaxy' cx='#{x}' cy='#{y}' rx='#{r}' ry = '#{r2}' />"
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
  lines = while i <= ra_2
    [x, y] = get_xy(i, deg)
    i += 1
    "#{x},#{y}"
  all_lines = lines.join(" ")
  "<polyline class='line' points='#{all_lines}' />"

generate_ra_line = (deg) ->
  i = dec_1
  lines = while i <= dec_2
    [x, y] = get_xy(deg, i)
    i += 1
    "#{x},#{y}"
  all_lines = lines.join(" ")
  "<polyline class='line' points='#{all_lines}' />"

get_xy = (ra, dec) ->
  ra = deg_to_rad(ra)
  dec = deg_to_rad(dec)
  cra = deg_to_rad(center_ra)

  ra_diff = ra - cra
  ra_diff += (2*Math.PI) if ra_diff <= -Math.PI
  ra_diff -= (2*Math.PI) if ra_diff >= Math.PI

  th = n * ra_diff
  #p = R * (G - dec)
  p = (G - dec)
  x = p * Math.sin(th)
  y = p0 - p * Math.cos(th)

  x = x * R * map_width + map_width / 2
  x = map_width - x
  x = Math.round(x*10)/10
  y = y * R * map_width + map_height / 2
  y = map_height - y
  y = Math.round(y*10)/10
  [x, y] 

deg_to_rad = (deg) ->
  deg * Math.PI / 180.0

