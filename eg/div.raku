use Map::Leaflet 'leaf';

leaf.add-marker: [ 40.7128, -74.0060 ], div => "New York City";
leaf.add-marker: 40.7589, -73.9851, div => "Empire State Building";
leaf.add-marker: %(:lat(40.7267), :lon(-73.9815)), div => "Tompkins Square Park";

leaf.add-geojson(q:to/GEOJSON/);
{
  "type": "Feature",
  "geometry": {
    "type": "LineString",
    "coordinates": [
      [-74.0060, 40.7128],
      [-73.9851, 40.7589],
      [-73.9815, 40.7267],
      [-74.0060, 40.7128]
    ]
  }
}
GEOJSON

leaf.add-marker: [40.7128, -74.0060], div => "you are here";

leaf.show;


