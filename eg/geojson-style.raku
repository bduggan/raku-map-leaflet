use Map::Leaflet;

# Create a map centered on New York City
my $map = Map::Leaflet.new;

# connect them with geojson
$map.add-geojson(
  %( :type<Feature>, :geometry(
    %( :type<LineString>, :coordinates(
      [
        [-74.0060, 40.7128],
        [-73.9831, 40.7589],
        [-73.9825, 40.7227],
        [-74.0060, 40.7128]
      ]
    ))
  )),
  style => { :color<red> }
);

my $layer = $map.create-geojson-layer(
  geojson => %( :type<Feature>, :geometry(
      %( :type<LineString>, :coordinates(
        [
          [-74.0060, 40.7128],
          [-73.9851, 40.7589],
          [-73.9815, 40.7267],
          [-74.0060, 40.7128]
        ]
      ))
    )),
  style => { :color<blue> }
);

spurt "map.html", $map.render;
say "wrote map.html";

