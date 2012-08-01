calc_route = (route) ->
  g_waypts = (set_g_waypt(waypt.latitude, waypt.longitude) for waypt in route.waypoints)
  avoidHighways = if route.slabs_allowed == "1" then false else true
  #marker = setup_marker()
  #marker.setPosition(g_waypts[0].location)
  #marker.setMap(map)
  i=0
  while i < g_waypts.length-1
    end = if i+9 < g_waypts.length then i+9 else g_waypts.length-1
    orig = g_waypts[i].location
    dest = g_waypts[end].location
    wpts = g_waypts.slice(i+1, end)
    calc_jump(orig, dest, wpts, avoidHighways)
    i = i + 9

set_g_waypt = (lat, lng) ->
  return (location: new google.maps.LatLng(lat, lng), stopover: false)
	
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

calc_jump = (orig, dest, wpts, avoidHighways) ->
  request = 
    origin: orig
    destination: dest
    waypoints: wpts
    travelMode: "DRIVING"
    avoidHighways: avoidHighways
    avoidTolls: avoidHighways
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

$('#info_pane').livequery ->
  top = Math.floor(window.innerHeight/2 - 200) + 'px'
  left = Math.floor(window.innerWidth/2 - 200) + 'px'
  $(this).css({'top': top, 'left': left})

$(document).ready ->
  $('.panel_link').click( (event) ->
    $('.panel').addClass('hidden')
    selector = '#' + $(this).data('panel')
    $(selector).toggleClass('hidden')	
  )
  $('#filter_panel > input[type="radio"]').click( (event) -> 
    path = '/' + $(this).attr('value') + '?bounds=' + window.map_canvas.getBounds().toUrlValue()
    window.location.assign(path)
  )
  $('#import_itn').click( (event) ->
    $('#itn_import_form').load('/itns/new')
    return false
  )
  $('#info_pane_close').click( (event) ->   
    $('#info_pane').addClass('hidden')
  )
  $('#route_slabs_allowed').click( (event) ->   
    redrawDirections()
  )
  $('#export_navigon').click( (event) ->   
    $('#info_pane_content').html(to_navigon(routes[0]))
    $('#info_pane').removeClass('hidden')
  )
  $('#export_itn').click( (event) ->   
    path = '/routes/export/' + routes[0]._id
    window.location.assign(path)
  )

to_navigon = (route) ->
  nav_waypts = (set_nav_waypt(waypt.latitude, waypt.longitude) for waypt in route.waypoints)
  nav_route_url = "navigonUSA-PA://route/?"
  $.each(nav_waypts, (i, wpt) ->
    nav_route_url += wpt
    nav_route_url += "&" if i < nav_waypts.length-1 )
  return nav_route_url

set_nav_waypt = (lat, lng) ->
  return "target=coordinate//#{lng}/#{lat}"