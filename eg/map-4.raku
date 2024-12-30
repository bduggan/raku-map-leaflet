use Map::Leaflet;

# Create a map centered on New York City
my $map = Map::Leaflet.new;

# Add markers
$map.add-marker({ :lat(40.7267), :lon(-73.9815) });

spurt "map.html", $map.generate-page;
say "wrote map.html";

