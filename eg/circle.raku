use Map::Leaflet;

my $map = Map::Leaflet.new;

# center in nyc
my $circle = $map.add-circle(
    center => [40.7128, -74.0060],
    radius => 500,
    color => 'red',
    fillColor => 'red',
    fillOpacity => 0.5,
);

spurt 'circle.html', $map.render;
say "wrote circle.html";
