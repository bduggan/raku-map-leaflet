use Map::Leaflet;

my $map = Map::Leaflet.new;
$map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");
$map.add-marker({ :lat(40.7589), :lon(-73.9851) }, "Empire State Building");
$map.add-marker( 40.7267, -73.9815, "Tompkins Square Park");

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

my $icon = $map.create-div-icon: html => "You are here";
$map.create-marker: latlng => [40.7128, -74.0060], options => %( icon => $icon );

$map.show;


