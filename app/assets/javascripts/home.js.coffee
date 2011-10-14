function initialize() {
	var myOptions = {
	  zoom: 14,
	  mapTypeId: google.maps.MapTypeId.ROADMAP,
	  center: haight
	}
	var haight = new google.maps.LatLng(37.7699298, -122.4469157);
	var oceanBeach = new google.maps.LatLng(37.7683909618184, -122.51089453697205);
	var gratton = new google.maps.LatLng(37.7628, -122.4509);
	var sunset = new google.maps.LatLng(37.7486, -122.4975);
	var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	calcRoute(map, haight, oceanBeach);
	calcRoute(map, gratton, sunset);
}

function calcRoute(map, orig, dest) {
	var directionsService = new google.maps.DirectionsService();
  var request = {
      origin: orig,
      destination: dest,
      travelMode: "DRIVING"
  };
	var directionsRenderer = new google.maps.DirectionsRenderer();
	directionsRenderer.setMap(map);
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsRenderer.setDirections(response);
    }
  });
}

window.onload = function() { initialize(); };
