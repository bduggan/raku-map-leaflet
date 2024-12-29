unit class Map::Leaflet:ver<0.0.1>;
use JSON::Fast;

has %.center = :lat(0), :lon(0);
has $.zoom = 13;
has $.width = '95vw';
has $.height = '95vh';
has $.extra-css = q:to/CSS/;
    #map {
      border: 1px solid #000;
      margin-left: auto;
      margin-right: auto;
   }
CSS

has $.leaflet-version = '1.9.4';
has $.leaflet-providers-version = '1.13.0';

# see https://leaflet-extras.github.io/leaflet-providers/preview/
has $.tile-provider = 'CartoDB.Positron';

has $.leaflet-css-url = 'https://unpkg.com/leaflet@' ~ $!leaflet-version ~ '/dist/leaflet.css';
has $.leaflet-js-url = 'https://unpkg.com/leaflet@' ~ $!leaflet-version ~ '/dist/leaflet.js';
has $.leaflet-providers-js-url = 'https://unpkg.com/leaflet-providers@' ~ $!leaflet-providers-version ~ '/leaflet-providers.js';

has @.markers;
has @.geojson-layers;

method add-marker(%coords, $popup?) {
    @!markers.push: {
        lat => %coords<lat>,
        lon => %coords<lon>,
        popup => $popup
    };
}

method add-geojson($geojson) {
    @!geojson-layers.push: $geojson;
}

method generate-page {
    my $markers-js = @!markers.map(-> $m {
        qq[L.marker([{$m<lat>}, {$m<lon>}])] ~
        ($m<popup> ?? qq[.bindPopup('{$m<popup>}')] !! '') ~
        '.addTo(map);'
    }).join("\n") // '';

    my $geojson-js = @!geojson-layers.map(-> $l {
        qq[L.geoJSON($l).addTo(map);]
    }).join("\n") // '';

    qq:to/END/;
    <html>
    <head>
        <title>Leaflet Map</title>
        <link rel="stylesheet" href="{$!leaflet-css-url}" />
        <script src="{$!leaflet-js-url}"></script>
        <script src="{$!leaflet-providers-js-url}"></script>
        <style>
            #map \{ height: {$!height}; width: {$!width}; \}
            $!extra-css
        </style>
    </head>
    <body>
        <div id="map"></div>
        <script>
            var map = L.map('map').setView([{%!center<lat>}, {%!center<lon>}], {$!zoom});
            L.tileLayer.provider('{$!tile-provider}').addTo(map);
            L.control.scale().addTo(map);
            $markers-js
            $geojson-js
        </script>
    </body>
    </html>
    END
}

=begin pod

=head1 NAME

Map::Leaflet - Generate maps using leaflet.js

=head1 SYNOPSIS

=begin code

use Map::Leaflet;

my $map = Map::Leaflet.new(
    center => { :lat(40.7128), :lon(-74.0060) },
    zoom => 13
);

$map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");
$map.add-marker({ :lat(40.7589), :lon(-73.9851) }, "Empire State Building");
$map.add-marker({ :lat(40.7267), :lon(-73.9815) }, "Tompkins Square Park");

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

spurt "map.html", $map.generate;

=end code

=head1 DESCRIPTION

Generate HTML that renders a map, using the excellent leaflet.js library.

=head1 METHODS

=head2 new

    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor.  Options (attributes of the object) are:

=head3 center

A hash with C<lat> and C<lon> keys.

=head3 zoom

The zoom level (integer).

=head3 width, height

The height and width of the map.  Defaults to 95vw and 95vh, respectively.

=head3 extra-css

Extra CSS to include in the HTML.  The default adds a border and centers the map.

=head3 tile-provider

The tile provider to use.  Defaults to 'CartoDB.Positron'.  For a complete list of providers, see L<https://leaflet-extras.github.io/leaflet-providers/preview/>.

Here are a few of the providers listed:  C<CartoDB.Positron>, C<OpenStreetMap.Mapnik>, C<Esri.WorldstreetMap>

=head3 leaflet-version, leaflet-providers-version

The version of leaflet.js and leaflet-providers.js to use.  Defaults to 1.9.4 and 1.13.0, respectively.

=head2 add-marker

    $map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");

Add a marker.  The first argument is a hash with C<lat> and C<lon> keys, and the second argument is an optional popup text.

=head2 add-geojson

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

Add a GeoJSON layer.  The argument is a string containing GeoJSON.

=method generate-page

    spurt "map.html", $map.generate;

Generate a complete HTML page for the map (including html, head, body, etc.).  Returns a string.

=head1 AUTHOR

Brian Duggan

=end pod

