window.onload = -> initialize()

initialize = -> 
  myOptions = 
		zoom:      14
		center:    haight
	haight = new google.maps.LatLng(37.7699298, -122.4469157)
	oceanBeach = new google.maps.LatLng(37.7683909618184, -122.51089453697205)
	gratton = new google.maps.LatLng(37.7628, -122.4509)
	sunset = new google.maps.LatLng(37.7486, -122.4975)
	map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
	calcRoute(map, haight, oceanBeach)
	calcRoute(map, gratton, sunset)
	
calcRoute = (map, orig, dest) ->
	directionsService = new google.maps.DirectionsService()
  request = 
    origin: orig
    destination: dest
    travelMode: "DRIVING"
	directionsRenderer = new google.maps.DirectionsRenderer()
	directionsRenderer.setMap(map)
  directionsService.route(request, (response, status) ->
    directionsRenderer.setDirections(response) if status == google.maps.DirectionsStatus.OK )


