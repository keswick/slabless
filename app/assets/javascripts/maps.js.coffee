# show_route = (map, route) ->

show_route = (map, route) ->
  g_waypts = (set_g_waypt(waypt.latitude, waypt.longitude) for waypt in route.waypoints)
  marker = setup_marker()
  marker.setPosition(g_waypts[0].location)
  marker.setMap(map)
  i=0
  while i < g_waypts.length-1
    end = if i+9 < g_waypts.length then i+9 else g_waypts.length-1
    orig = g_waypts[i].location
    dest = g_waypts[end].location
    wpts = g_waypts.slice(i+1, end)
    calc_route(map, true, orig, dest, wpts)
    i = i + 9

set_g_waypt = (lat, lng) ->
  return (location: new google.maps.LatLng(lat, lng), stopover: false)

setup_map = ->
  mapOptions = 
    zoom: 14
    mapTypeId: google.maps.MapTypeId.ROADMAP
  map = new google.maps.Map(document.getElementById("route_canvas"), mapOptions);
	
setup_marker = ->
  marker_image = new google.maps.MarkerImage('/assets/motorcycling.png')
  marker_shadow = new google.maps.MarkerImage('/assets/motorcycling.shadow.png')
  marker = new google.maps.Marker(
    draggable: true
    icon: marker_image
    shadow: marker_shadow
    )

render_route = (map, directions_response) ->
  renderOptions = suppressMarkers: true
  renderer = new google.maps.DirectionsRenderer(renderOptions)
  renderer.setMap(map)
  renderer.setDirections(directions_response)

calc_route = (map, render_flag, orig, dest, wpts) ->
  request = 
    origin: orig
    destination: dest
    waypoints: wpts
    travelMode: "DRIVING"
    avoidHighways: true
    avoidTolls: true
  dirService = new google.maps.DirectionsService()
  dirService.route(request, (response, status) ->
    if status == google.maps.DirectionsStatus.OK
      render_route(map, response) if render_flag == true
      window.jumps.push(response)
      $("#r_zone").append JSON.stringify(response)
  )
	
$('#route_canvas').livequery ->
  map = setup_map()
  window.jumps = new Array
  show_route(map, route) for route in routes
