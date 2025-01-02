use Map::Leaflet;

# Create a map centered on New York City
my $map = Map::Leaflet.new;

# Add markers
$map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");
$map.add-marker({ :lat(40.7589), :lon(-73.9851) }, "Empire State Building");
$map.add-marker({ :lat(40.7267), :lon(-73.9815) }, "Tompkins Square Park");

# connect them with geojson
$map.add-geojson(q:to/GEOJSON/);
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

spurt "map.html", $map.render;
say "wrote map.html";

