unit class Map::Leaflet:ver<0.0.1>;
use JSON::Fast;

has %.center; # :lat(0), :lon(0);
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

has $.title = 'Map';
has $.leaflet-version = '1.9.4';
has $.leaflet-providers-version = '1.13.0';

# see https://leaflet-extras.github.io/leaflet-providers/preview/
has $.tile-provider = 'CartoDB.Positron';

has $.leaflet-css-url = 'https://unpkg.com/leaflet@' ~ $!leaflet-version ~ '/dist/leaflet.css';
has $.leaflet-js-url = 'https://unpkg.com/leaflet@' ~ $!leaflet-version ~ '/dist/leaflet.js';
has $.leaflet-providers-js-url = 'https://unpkg.com/leaflet-providers@' ~ $!leaflet-providers-version ~ '/leaflet-providers.js';

has @.markers;
has @.geojson-layers;

method add-marker(%coords where { $_<lat>:exists and $_<lon>:exists } , $popup?) {
    @!markers.push: %( |%coords, :$popup );
}

method add-geojson($geojson) {
    @!geojson-layers.push: $geojson;
}

method generate-page {
    my $markers-js = @!markers.map(-> $m {
        qq:to/JS/;
        bounds.extend([{$m<lat>}, {$m<lon>}]);
        all_layers.push(
          L.marker([{$m<lat>}, {$m<lon>}], \{title: "{$m<popup>}"})
            .addTo(map)
            .bindPopup("{$m<popup>}")
        );
        JS
    }).join("\n") // '';

    my $geojson-js = @!geojson-layers.map(-> $l {
      # qq[L.geoJSON($l).addTo(map);]
      qq:to/JS/;
      L.geoJSON($l).addTo(map);
      bounds.extend(L.geoJSON($l).getBounds());
      JS
    }).join("\n") // '';

    my $start-pos = %!center<lat>.defined ??
    "map.setView([{%!center<lat>}, {%!center<lon>}], {$!zoom});" !!
    "map.fitBounds(bounds);";

    qq:to/END/;
    <!DOCTYPE html>
    <html>
    <head>
        <title>{ $.title }</title>
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
            var map = L.map('map');
            L.tileLayer.provider('{$!tile-provider}').addTo(map);
            L.control.scale().addTo(map);
            let bounds = L.latLngBounds();
            let all_layers = [];
            $markers-js
            $geojson-js
            $start-pos
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

my $map = Map::Leaflet.new;
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

spurt "map.html", $map.generate-page;

=end code

![output](https://github.com/user-attachments/assets/fd0b1a5f-ec57-4007-b5dd-a5daa10c85f7)

=head1 DESCRIPTION

Generate HTML that renders a map, using the excellent leaflet.js library.

=head1 METHODS

=head2 new

    my $map = Map::Leaflet.new;
    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor.  If no center is specified, then it will fit
the bounds of all markers and geojson layers.

Other options are:

=head4 title

The title of the HTML page.  Defaults to 'Map'.

=head4 center

A hash with C<lat> and C<lon> keys.

=head4 zoom

The zoom level (integer).

=head4 width, height

The height and width of the map.  Defaults to 95vw and 95vh, respectively.

=head4 extra-css

Extra CSS to include in the HTML.  The default adds a border and centers the map.

=head4 tile-provider

The tile provider to use.  Defaults to 'CartoDB.Positron'.  For a complete list of providers, see L<https://leaflet-extras.github.io/leaflet-providers/preview/>.

Here are a few of the providers listed:  C<CartoDB.Positron>, C<OpenStreetMap.Mapnik>, C<Esri.WorldstreetMap>

=head4 leaflet-version, leaflet-providers-version

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

=head2 generate-page

    spurt "map.html", $map.generate-page;

Generate a complete HTML page for the map (including html, head, body, etc.).  Returns a string.

=head1 SEE ALSO

L<https://leafletjs.com/>

=head1 AUTHOR

Brian Duggan

=end pod

