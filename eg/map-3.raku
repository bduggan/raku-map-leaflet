use Map::Leaflet;

# Create a map centered on New York City
my $map = Map::Leaflet.new;

# connect them with geojson
$map.add-geojson(q:to/GEOJSON/, style => { color => 'red' });
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

spurt "map.html", $map.generate-page;
say "wrote map.html";
