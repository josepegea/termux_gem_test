var map = L.map('mapid').fitWorld();

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
	maxZoom: 18,
	attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
		'<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
		'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
	id: 'mapbox.streets'
}).addTo(map);

function onLocationFound(e) {
	var radius = e.accuracy / 2;

	L.marker(e.latlng).addTo(map);
	L.circle(e.latlng, radius).addTo(map);
}

function onLocationError(e) {
	alert(e.message);
}

map.on('locationfound', onLocationFound);
map.on('locationerror', onLocationError);

map.locate({setView: true, maxZoom: 16});

// Get the JSON data
$(() => {
  var day = $("#datepicker").val();
  showDayLocations(day);

  $("#datepicker").change((event) => {
    showDayLocations($(event.target).val());
  });
});

var dayLayer;

function showDayLocations(day = null) {
  var url = '/location_data.json';
  if (day) {
    url += ('?day=' + day);
  }
  $.ajax(url).done((data) => {
    if (dayLayer) {
      dayLayer.removeFrom(map);
    }
    dayLayer = L.geoJSON(JSON.parse(data));
    dayLayer.addTo(map);
    map.fitBounds(dayLayer.getBounds());
  });
}
