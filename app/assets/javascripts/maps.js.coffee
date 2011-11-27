create_map = ->
  myOptions = 
    zoom: 14
    mapTypeId: google.maps.MapTypeId.ROADMAP
  map = new google.maps.Map(document.getElementById("route_canvas"), myOptions);
  calcRoute(map)
	# calcRoute(map, gratton, sunset)
	
calcRoute = (map) ->
  marker_image = new google.maps.MarkerImage('/assets/motorcycling.png')
  marker_shadow = new google.maps.MarkerImage('/assets/motorcycling.shadow.png')
  directionsService = new google.maps.DirectionsService()
  renderOptions =
    suppressMarkers: true
  directionsRenderer = new google.maps.DirectionsRenderer(renderOptions)
  directionsRenderer.setMap(map)
  orig = waypts.shift()
  dest = waypts.pop()
  marker = new google.maps.Marker(
    draggable: true
    icon: marker_image
    shadow: marker_shadow
    map: map
    position: orig.location
    )
  request = 
    origin: orig.location
    destination: dest.location
    waypoints: waypts
    travelMode: "DRIVING"
    avoidHighways: true
    avoidTolls: true
  directionsService.route(request, (response, status) ->
	  directionsRenderer.setDirections(response) if status == google.maps.DirectionsStatus.OK )
	
$('#route_canvas').livequery ->
	create_map()
