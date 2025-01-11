use Map::Leaflet;

my $map = Map::Leaflet.new;

# center in nyc
my $circle = $map.create-circle(
    center => [40.7128, -74.0060],
    radius => 500,
    color => 'red',
    fillColor => 'red',
    fillOpacity => 0.5,
);

$map.add-circle( 40.7128, -74.0060, 100, { color => 'blue' } );

$map.show;
