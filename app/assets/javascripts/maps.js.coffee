calc_route = (route) ->
  g_waypts = (set_g_waypt(waypt.latitude, waypt.longitude) for waypt in route.waypoints)
  #marker = setup_marker()
  #marker.setPosition(g_waypts[0].location)
  #marker.setMap(map)
  i=0
  while i < g_waypts.length-1
    end = if i+9 < g_waypts.length then i+9 else g_waypts.length-1
    orig = g_waypts[i].location
    dest = g_waypts[end].location
    wpts = g_waypts.slice(i+1, end)
    calc_jump(orig, dest, wpts)
    i = i + 9

set_g_waypt = (lat, lng) ->
  return (location: new google.maps.LatLng(lat, lng), stopover: false)

# setup_map = ->
  # mapOptions = zoom: 14, mapTypeId: google.maps.MapTypeId.ROADMAP
  # new google.maps.Map(document.getElementById("map_canvas"), mapOptions)
	
setup_marker = ->
  marker_image = new google.maps.MarkerImage('/assets/motorcycling.png')
  marker_shadow = new google.maps.MarkerImage('/assets/motorcycling.shadow.png')
  marker = new google.maps.Marker(
    draggable: true
    icon: marker_image
    shadow: marker_shadow
    )

render_route = (directions_response) ->
  renderOptions = suppressMarkers: true
  renderer = new google.maps.DirectionsRenderer(renderOptions)
  renderer.setMap(window.map_canvas)
  renderer.setDirections(directions_response)

calc_jump = (orig, dest, wpts) ->
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
      render_route(response)
      window.jumps.push(response)
  )
	
$('#map_canvas').livequery ->
  mapOptions = zoom: 8, center: new google.maps.LatLng(40.5310, -76.685), mapTypeId: google.maps.MapTypeId.ROADMAP
  window.map_canvas = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  window.jumps = new Array
  calc_route(route) for route in routes
  if bounds?
    google.maps.event.addListener(window.map_canvas, 'idle', ->
      window.map_canvas.fitBounds(bounds)
      # window.map_canvas.setZoom(window.map_canvas.getZoom + 2)
      google.maps.event.addListenerOnce(window.map_canvas, 'mousemove', ->
        google.maps.event.clearListeners(window.map_canvas, 'idle')
      )
    )

$('form.edit_route').livequery ->
  $(this).submit( (event) ->
    jumps = ""
    $.each(window.jumps, (i, rte) ->
      jumps += JSON.stringify(rte)
      jumps += '--BREAK--'
    )
    $('#route_jumps').val(jumps)
  )

$('#show_routes_within_map').livequery ->
  $(this).click( (event) ->   
    this.href += '?bounds=' + window.map_canvas.getBounds().toUrlValue()
  )

$('#expand_waypoints').livequery ->
  $(this).click( (event) ->   
    $('#route_waypoints').toggleClass('hidden')
  )


