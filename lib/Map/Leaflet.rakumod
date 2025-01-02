unit class Map::Leaflet:ver<0.0.1>;
use JSON::Fast;

subset PointStr of Str where { $_ eq 'auto' or /:s ^ '[' \d+ ',' \d+ ']' $/ };

my role LeafObject {
  method construct-options(Set :$exclude) {
    my %values;
    for self.^attributes.list -> $attr {
      my $value = $attr.get_value(self);
      next unless defined($value);
      # remove sigil
      my $key = $attr.name.subst( / <-[a..zA..Z0..9-]>+ /, '', :g );
      next if $key eq 'name';
      next if $exclude && $key (elem) $exclude;
      %values{ $key } = $value;
    }
    return %values;
  }

  method construct-option-string(Set :$exclude) {
    my %values = self.construct-options(:$exclude);
    return option-string(%values);
  }

  method Str { $.name }
}

my class Icon does LeafObject {
  my $index = 0;
  has $.name = 'icon_' ~ ($index++);

  has $.iconUrl;
  has $.iconRetinaUrl;
  has PointStr $.iconSize;
  has PointStr $.iconAnchor;
  has PointStr $.popupAnchor;
  has PointStr $.tooltipAnchor;
  has $.shadowUrl;
  has $.shadowRetinaUrl;
  has PointStr $.shadowSize;
  has PointStr $.shadowAnchor;
  has $.className;
  has Bool $.crossOrigin;

  method render {
    my $opts-str = self.construct-option-string;
    return Q:s:to/JS/;
      let $.name = L.icon($opts-str)
    JS
  }
}

my class DivIcon is Icon {
  my $index = 0;
  has $.name = 'div_icon_' ~ ($index++);
  has $.html;
  has PointStr $.bgPos;
  has PointStr $.iconSize = 'auto';
  has $.className = 'mlraku-div-icon';
  
  method render {
    my $opts-str = self.construct-option-string;
    return Q:s:to/JS/;
      let $.name = L.divIcon($opts-str)
    JS
  }
}

my class Layer {
  has $.attribution;
}

my class InteractiveLayer is Layer {
  has Bool $.interactive;
}

my class Marker is InteractiveLayer does LeafObject {
  my $index = 0;
  has $.name = 'marker_' ~ ($index++);
  has $.popup-text;
  has Numeric @.latlng;

  has Icon $.icon;
  has Bool $.keyboard;
  has Str $.title;
  has Str $.alt;
  has $.zIndexOffset;
  has Rat $.opacity;
  has Bool $.riseOnHover;
  has $.pane;
  has $.shadowPane;

  has Bool $.bubblingMouseEvents;
  has Bool $.autoPanOnFocus = False;
  has Bool $.draggable;
  has Bool $.autoPan = False;
  has PointStr $.autoPanPanning;
  has Int $.autoPanSpeed;

  method render-latlng {
    return '[' ~ @!latlng.join(', ') ~ ']';
  }

  method render {
    my $opts-str = self.construct-option-string(exclude => set <latlng popup-text> );
    my $latlng = self.render-latlng;
    my $popup-js = "";
    if $!popup-text.defined {
      $popup-js = qq:to/JS/.trim;
        .bindPopup('{ escape-val($!popup-text) }')
      JS
    }
    return Q:s:to/JS/;
      let $.name = L.marker($latlng, $opts-str)$popup-js;
      JS
  }
}

sub escape-val(Str $val) {
  $val.subst(:g,  / "'" /, "\\'").subst(:g, "\n", "\\n");
}


sub quote-value($value) {
  given $value {
    when PointStr { $value eq 'auto' ?? "'auto'" !! $value }
    when Str { "'" ~ escape-val($value) ~ "'" }
    when Bool { $value ?? 'true' !! 'false' }
    default { $value.Str }
  }
}

sub option-string(%options) {
  '{' ~
  %options.map({ .key ~ ': ' ~ quote-value(.value) }).join(', ')
  ~ '}';
}

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
   .mlraku-div-icon {
      background-color: yellow;
      border: 1px solid black;
      padding: 2px;
      border-radius: 2px;
      opacity: 0.8;
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
has Icon @.icons;

method add-geojson($geojson, :$style) {
    @!geojson-layers.push: %( :$geojson, :$style );
}

method create-div-icon(*%options) {
  my $new = DivIcon.new(|%options);
  @!icons.push: $new;
  $new;
}

method create-icon(*%options) {
  my $new = Icon.new(|%options);
  @!icons.push: $new;
  $new;
}

method create-marker(:@latlng, :%options) {
  my $new = Marker.new(:@latlng, |%options);
  @!markers.push: $new;
  $new;
}

method add-marker(
  %coords where { $_<lat>:exists and $_<lon>:exists },
  $popup-text?
) {
  self.create-marker(:latlng(%coords<lat>, %coords<lon>), options => %( :$popup-text ) );
}

method render {
    my $icons-js = @!icons.map: { .render.indent(6) };

    my $markers-js = "";
    for @!markers -> $m {
      $markers-js ~= qq:to/JS/.indent(8);
      bounds.extend({ $m.render-latlng });
      { $m.render.trim-trailing }
      { $m.name }.addTo(map);
      JS
    }

    my $geojson-js = "";
    for @!geojson-layers -> $l {
      my $geojson = $l<geojson> ~~ Str ?? $l<geojson> !! to-json($l<geojson>);
      my $style =    !$l<style> ?? ''
                  !! $l<style> ~~ Str ?? $l<style>
                  !! to-json($l<style>);
      $geojson-js ~= qq:to/JS/;
      all_layers.push(
        L.geoJSON($geojson, $style).addTo(map)
      );
      bounds.extend(all_layers[all_layers.length - 1].getBounds());
      JS
    }

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
            L.tileLayer.provider('{$.tile-provider}').addTo(map);
            L.control.scale().addTo(map);
            let bounds = L.latLngBounds();
            let all_layers = [];
$icons-js
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

spurt "map.html", $map.render;

=end code

![output](https://github.com/user-attachments/assets/fd0b1a5f-ec57-4007-b5dd-a5daa10c85f7)

=head1 DESCRIPTION

Generate HTML that renders a map, using the excellent leaflet.js library.

The C<Map::Leaflet> class represents a map which can be rendered as HTML.
Use a map object to create objects which are analogous to their javascript
counterparts, and then render the entire page to generate the javascript.

There are default values for many of the leaflet objects, in an attempt to
make common cases work more easily out of the box.

=head1 METHODS

=head2 new

    my $map = Map::Leaflet.new;
    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor.  If no center is specified, then bounds are computed, and
the starting view will have a zoom level and extents that fit all of
the layers that have been added.

Other options to the constructor are:

=head4 title

The title of the HTML page.  Defaults to 'Map'.

=head4 center

A hash with C<lat> and C<lon> keys.

=head4 zoom

The zoom level (integer).

=head4 width, height

The height and width of the map.  Defaults to 95vw and 95vh, respectively.

=head4 extra-css

Extra CSS to include in the HTML.  The default adds a border, centers the map,
and provides a class for div-icons.

=head4 tile-provider

The tile provider to use.  Defaults to 'CartoDB.Positron'.  For a complete list of providers, see L<https://leaflet-extras.github.io/leaflet-providers/preview/>.

Here are a few of the providers listed:  C<CartoDB.Positron>, C<OpenStreetMap.Mapnik>, C<Esri.WorldstreetMap>

=head4 leaflet-version, leaflet-providers-version

The version of leaflet.js and leaflet-providers.js to use.  Defaults to 1.9.4 and 1.13.0, respectively.

=head2 add-marker

    $map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");

Add a marker.  The first argument is a hash with C<lat> and C<lon> keys, and the second argument
is an optional popup text.  See C<create-marker> below for a more flexible way to create markers.

=head2 create-div-icon

    my $div-icon = $map.create-div-icon(html => '<b>New York City</b>');
    my $div-icon = $map.create-div-icon: html => '<b>Paris</b>', iconSize => 'auto', className => 'mlraku-div-icon';

Create a divIcon.  Accepts all of the leaflet.js options.  See L<https://leafletjs.com/reference.html#divicon>.
Defaults to auto-sizing, a yellow background, and a black border, and a class of 'mlraku-div-icon'.

Also accepts a C<name> option, which is used to name the icon in the javascript (defaults to an auto-generated name).

Returns a C<Map::Leaflet::DivIcon> object.

=head2 create-icon

    my $icon = $map.create-icon(iconUrl => 'https://leafletjs.com/examples/custom-icons/leaf-green.png');
    my $icon = $map.create-icon: iconUrl => 'https://leafletjs.com/examples/custom-icons/leaf-green.png', iconSize => '[38, 95]';

Create an icon.  Accepts all of the leaflet.js options.  See L<https://leafletjs.com/reference.html#icon>.
Note that the iconSize, iconAnchor, popupAnchor, and tooltipAnchor are all C<PointStr> objects, which can be either
a string of the form "[x, y]" or the string "auto".

=head2 create-marker

  $map.create-marker(latlng => [ $lat, $lon ], options => %( icon => $icon ));
  $map.create-marker: latlng => [ $lat, $lon ], options => %( title => 'New York City', popup-text => 'The Big Apple' );

Create a marker.  Accepts all of the leaflet.js options.  See L<https://leafletjs.com/reference.html#marker>.
Also accepts popup-text as an option to generate a popup that is bound to the marker.

Defaults to False values for autoPan and autoPanFocus.

=head2 add-geojson

    $map.add-geojson($geojson, $style);
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
    $map.add-geojson(
      %( :type<Feature>, :geometry(
        %( :type<LineString>, :coordinates(
          [
            [-74.0060, 40.7128],
            [-73.9851, 40.7589],
            [-73.9815, 40.7267],
            [-74.0060, 40.7128]
          ]
        ))
      )),
      style => { :color<red> }
    );

Add a GeoJSON layer. C<$geojson> can be a string or a hash.  C<$style> is optional and can also
be a string or a hash.

=head2 render

    spurt "map.html", $map.render;

Generate a complete HTML page for the map (including html, head, body, etc.).  Returns a string.

=head1 SEE ALSO

L<https://leafletjs.com/>

=head1 AUTHOR

Brian Duggan

=end pod

