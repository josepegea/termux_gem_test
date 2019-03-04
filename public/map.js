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

let pathLayer, pathData;
let locationsLayer, locationsData;
let sensorStatusesLayer, sensorStatusesData;

function showDayLocations(day = null) {
  var url = '/location_data.json';
  if (day) {
    url += ('?day=' + day);
  }
  $.ajax(url).done((data) => {
    if (pathLayer) {
      pathLayer.removeFrom(map);
    }
    if (locationsLayer) {
      locationsLayer.removeFrom(map);
    }
    if (sensorStatusesLayer) {
      sensorStatusesLayer.removeFrom(map);
    }
    let jsonData = JSON.parse(data);
    if (pathData = jsonData.path) {
      pathLayer = L.geoJSON(pathData);
      pathLayer.addTo(map);
    }
    if (locationsData = jsonData.locations) {
      locationsLayer = L.geoJSON(locationsData, {pointToLayer: pointToLayer, onEachFeature: onEachFeature});
      locationsLayer.addTo(map);
    }
    if (sensorStatusesData = jsonData.sensor_statuses) {
      sensorStatusesLayer = L.geoJSON(sensorStatusesData, {pointToLayer: sensorPointToLayer, onEachFeature: onEachFeature});
      sensorStatusesLayer.addTo(map);
    }
    map.fitBounds(pathLayer.getBounds());
  });
}

function pointToLayer(feature, latlng) {
  return L.circleMarker(latlng, {radius: 4 } );
}

function onEachFeature(feature, layer) {
  if (feature.properties) {
    layer.bindPopup(contentForPopup(feature.properties));
  }
}

function sensorPointToLayer(feature, latlng) {
  return L.circleMarker(latlng, {radius: 4, color: colorForSensorFeature(feature) } );
}

function colorForSensorFeature(feature) {
  const colorsForFeatures = {
    0: "#008",
    1: "#228",
    2: "#428",
    3: "#628",
    4: "#828",
    5: "#826",
    6: "#824",
    7: "#822",
    8: "#800"
  };

  if (!feature || !feature.properties || !feature.properties.motion_type) {
    return "#444";
  }
  return colorsForFeatures[feature.properties.motion_type] || "#444";
}

function onEachFeature(feature, layer) {
  if (feature.properties) {
    layer.bindPopup(contentForPopup(feature.properties));
  }
}

function contentForPopup(props) {
  let terms = Object.keys(props).map((k) => `<dt>${k}</dt><dd>${props[k]}</dd>`);
  return `<dl>${terms.join(' ')}</dl>`
}
