use Map::Leaflet;

my $pacific = {
    type => 'Feature',
    geometry => {
        type => 'LineString',
        coordinates => [
            [
                [-125, 49],
                [-125, 32],
                [-114, 32],
                [-114, 49],
                [-125, 49],
            ]
        ],
    }
};

my $map = Map::Leaflet.new;
$map.add-geojson: $pacific;
spurt 'out.html', $map.render;
shell "open 'out.html'";


