create_map = ->
	haight = new google.maps.LatLng(37.7699298, -122.4469157);
	oceanBeach = new google.maps.LatLng(37.7683909618184, -122.51089453697205)
	gratton = new google.maps.LatLng(37.7628, -122.4509)
	sunset = new google.maps.LatLng(37.7486, -122.4975)
	myOptions = 
  	zoom: 14
  	mapTypeId: google.maps.MapTypeId.ROADMAP
  	center: haight
  map = new google.maps.Map(document.getElementById("route_canvas"), myOptions);
  waypoints = []
  waypoints.push 
    location: gratton
    stopover: false
  calcRoute(map, haight, oceanBeach, waypoints)
	# calcRoute(map, gratton, sunset)
	alert "Hello 2"
	
calcRoute = (map, orig, dest, waypts) ->
	directionsService = new google.maps.DirectionsService()
	directionsRenderer = new google.maps.DirectionsRenderer()
	directionsRenderer.setMap(map)
	request = 
    origin: orig
    destination: dest
    travelMode: "DRIVING"
    waypoints: waypts
  directionsService.route(request, (response, status) ->
	  directionsRenderer.setDirections(response) if status == google.maps.DirectionsStatus.OK )
	
$('#route_canvas').livequery ->
	create_map()
