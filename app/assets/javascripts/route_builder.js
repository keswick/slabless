/**************************************************
 *                      Menu
 **************************************************/
 
function Menu($div){
  var that = this, 
      ts = null;
  
  this.$div = $div;
  this.items = [];
  
  // create an item using a new closure 
  this.create = function(item){
    var $item = $('<div class="menu_item '+item.cl+'">'+item.label+'</div>');
    $item
      // bind click on item
      .click(function(){
        if (typeof(item.fnc) === 'function'){
          item.fnc.apply($(this), []);
        }
      })
      // manage mouse over coloration
      .hover(
        function(){$(this).addClass('hover');},
        function(){$(this).removeClass('hover');}
      );
    return $item;
  };
  this.clearTs = function(){
    if (ts){
      clearTimeout(ts);
      ts = null;
    }
  };
  this.initTs = function(t){
    ts = setTimeout(function(){that.close()}, t);
  };
}

// add item
Menu.prototype.add = function(label, cl, fnc){
  this.items.push({
    label:label,
    fnc:fnc,
    cl:cl
  });
}

// close previous and open a new menu 
Menu.prototype.open = function(event){
  this.close();
  var k,
      that = this,
      offset = {
        x:0, 
        y:0
      },
      $menu = $('<div id="menu"></div>');
      
  // add items in menu
  for(k in this.items){
    $menu.append(this.create(this.items[k]));
  }
  
  // manage auto-close menu on mouse hover / out
  $menu.hover(
    function(){that.clearTs();},
    function(){that.initTs(3000);}
  );
  
  // change the offset to get the menu visible (#menu width & height must be defined in CSS to use this simple code)
  if ( event.pixel.y + $menu.height() > this.$div.height()){
    offset.y = -$menu.height();
  }
  if ( event.pixel.x + $menu.width() > this.$div.width()){
    offset.x = -$menu.width();
  }
  
  // use menu as overlay
  this.$div.gmap3({
    action:'addOverlay',
    latLng: event.latLng,
    content: $menu,
    offset: offset
  });
  
  // start auto-close
  this.initTs(5000);
}

// close the menu
Menu.prototype.close = function(){
  this.clearTs();
  this.$div.gmap3({action:'clear', name:'overlay'});
}


/**************************************************
 *                      Main
 **************************************************/

$('#route_builder_map').livequery(function(){

  var $map = $('#route_builder_map'), 
      menu = new Menu($map),
      
      current,  // current click event (used to save as start / end position)
      center = [40.5310, -76.685];
  
  // update marker
  function updateMarker(marker, isM1){
    if (isM1){
      m1 = marker;
    } else {
      m2 = marker;
    }
    updateDirections();
  }
  
  // add marker and manage which one it is (A, B)
  function addMarker(){
    // add marker and store it
		var ll_id = toSelector(current.latLng);
    $map.gmap3({
      action:'addMarker',
      latLng:current.latLng,
      options:{
        draggable:false,
        icon:new google.maps.MarkerImage('/assets/motorcycle.png')
      },
      tag: ll_id,
      events: {
        rightclick: function(marker, event){
				  console.log('in click event');
				  var map = $(this).gmap3('get'),
				    infowindow = $(this).gmap3({action:'get', name:'infowindow'});
					ll_id = toSelector(marker.getPosition());
					delete_link_html = '<a class="menu_item delete" href="#" onclick="deleteWaypoint(this)" data-tag="' + ll_id + '">Delete this Waypoint</a>'
				  if (infowindow){
				    infowindow.open(map, marker);
				    infowindow.setContent(delete_link_html);
				  } else {
				    $(this).gmap3({action:'addinfowindow', anchor:marker, options:{content: delete_link_html}});
				  }
				}
      },
      callback: function(marker){
				writeWaypointLI(marker);
				updateDirections($map, ll_id);
      }
    });
  }

  function writeWaypointLI(marker){
		var ul = $('#route_waypoints ul');
		var max_height = ($('#route_builder_map').height() * .75) - ($('#route_box').height() - ul.height());
		if (ul.height() < max_height) { ul.height("auto") };
		ul.append('<li id="' + toSelector(current.latLng) + '" class="sortable_icon"></li>');
		ul.height(ul.height());
	  $map.gmap3({
			action: 'getAddress',
			latLng: marker.getPosition(),
			callback: function(results){
				address = results && results[0] ? results && results[0].formatted_address : 'no address';
				content = address.replace(/(.*),.*$/, "$1");
				ll = toSelector(current.latLng);
				$('#' + ll).html(content);
			}
		});
		$('#route_waypoints').scrollTop(10000);
	}

  // MENU : ITEM 1
  menu.add('Add Waypoint', 'waypoint separator', 
    function(){
      menu.close();
      addMarker();
    });
  
  // MENU : ITEM 2
  menu.add('Zoom in', 'zoomIn', 
    function(){
      var map = $map.gmap3('get');
      map.setZoom(map.getZoom() + 1);
      menu.close();
    });
  
  // MENU : ITEM 3
  menu.add('Zoom out', 'zoomOut',
    function(){
      var map = $map.gmap3('get');
      map.setZoom(map.getZoom() - 1);
      menu.close();
    });
  
  // MENU : ITEM 4
  menu.add('Center here', 'centerHere', 
    function(){
        $map.gmap3('get').setCenter(current.latLng);
        menu.close();
    });
  
  // INITIALIZE GOOGLE MAP
  $map.gmap3(
    { action: 'init',
      options:{
        center:center,
        zoom: 8
      },
      events:{
        rightclick:function(map, event){
          current = event;
          menu.open(current);
        },
        click: function(){
          menu.close();
        },
        dragstart: function(){
          menu.close();
        },
        zoom_changed: function(){
          menu.close();
        }
      }
    }
  );
});

// function called to update directions
function updateDirections($map, selector){
	var prev_li = $('#' + selector).prev();
	var origin_wpt = toLatLng(prev_li.attr('id'));
	if (!origin_wpt) return;
	var dest_wpt = toLatLng(selector)
	$map.gmap3({
    action:'getRoute',
    options:{
      origin:origin_wpt,
      destination:dest_wpt,
      travelMode: google.maps.DirectionsTravelMode.DRIVING,
			avoidHighways: true
    },
    callback: function(results){
      if (!results) return;
			var meters = results.routes[0].legs[0].distance.value;
			var seconds = results.routes[0].legs[0].duration.value;
			setDistanceAndTime(meters, seconds);
			$(this).gmap3({
			  action:'addDirectionsRenderer',
			  options:{
				  preserveViewport: true,
				  suppressMarkers: true,
				  draggable: false,
				  directions:results 
				}
			});
  	}
  });
}

function setDistanceAndTime(meters, seconds) {
	var $div = $('#distance_duration');
	var total_meters = $div.data('meters') + meters;
	var miles = Math.floor(total_meters / 1609.344);
	var total_seconds = $div.data('seconds') + seconds;
	var duration = secondsToTime(total_seconds);
	var content = miles + ' miles - about ';
	if (duration.h > 0) { content += duration.h + ' hours ' };
	content += duration.m + ' minutes';
	$div.text(content);
	$div.data('meters', total_meters);
	$div.data('seconds', total_seconds);
}

function secondsToTime(secs)
{
	var hours = Math.floor(secs / (60 * 60));
	
	var divisor_for_minutes = secs % (60 * 60);
	var minutes = Math.floor(divisor_for_minutes / 60);

	var divisor_for_seconds = divisor_for_minutes % 60;
	var seconds = Math.ceil(divisor_for_seconds);
	
	var obj = {
		"h": hours,
		"m": minutes,
		"s": seconds
	};
	return obj;
}

function toSelector(latlng){
  var ll = latlng.lat().toString() + 'BREAK' + latlng.lng().toString();
  return ll.replace(/\./g,"_");
}

function toLatLng(id) {
  if (!id) return;
  var ll = id.replace(/_/g,".");
  var ll_split = ll.split('BREAK');
  return new google.maps.LatLng(ll_split[0], ll_split[1]);
}

function deleteWaypoint(control) {
	var tag = control.getAttribute("data-tag");
	var $map = $('#route_builder_map');
	var clear = {action:'clear', name:'marker', tag:''};
	clear.tag = tag;
	$map.gmap3(clear);
	var li = $('#' + tag);
	var ul = li.parent();
	// ul.css("height","auto");
	li.remove();
	// ul.height(ul.height());
	redrawDirections($map);
}

function redrawDirections($map) {
	var clear = {action:'clear', name:'directionrenderer'};
	$map.gmap3(clear);
	clearDistanceDurationTotals();
	$('#route_waypoints li').each(function(index, listItem) {
		updateDirections($map, listItem.id); 
	});
}

function clearDistanceDurationTotals() {
	var $div = $('#distance_duration');
	$div.data("seconds", 0);
	$div.data("meters", 0);
}

$('#sortable_waypoints').livequery(function(){
	$(this).sortable({
		axis:   'y',
		containment: 'parent',
		revert: 50,
		tolerance: 'pointer',
		cursor: 'move',
	  update: function(event, ui) {
			$map = $('#route_builder_map');
			redrawDirections($map);
		}
	});
	$(this).disableSelection();
});
  