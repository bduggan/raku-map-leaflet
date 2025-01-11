use JSON::Fast;
use Map::Leaflet::LatLng;
use Map::Leaflet::Path;
use Map::Leaflet::Icon;
use Map::Leaflet::Marker;
use Map::Leaflet::Utils;

unit class Map::Leaflet;
also does LeafObject;

has Bool $.fit-bounds = True;
has $.center = Map::Leaflet::LatLng.new( :lat(0), :lng(0) );
has $.zoom = 13;
has $.width = '95vw';
has $.height = '95vh';
has $.border = '1px solid #000';
has $.output-path = 'map-leaflet-tmp.html';

method map-css {
  qq:to/CSS/;
      #map \{
        width: $!width;
        height: $!height;
        border: $!border;
      }
  CSS
}
has $.extra-css = q:to/CSS/;
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
has Map::Leaflet::Icon @.icons;
has @.layers;

has $.preferCanvas;
has $.attributionControl;
has $.zoomControl;
has $.closePopupOnClick;
has $.boxZoom;
has $.doubleClickZoom;
has $.dragging;
has $.zoomSnap;
has $.zoomDelta;
has $.trackResize;

# panning inertia options
has $.inertia;
has $.inertiaDeceleration;
has $.inertiaMaxSpeed;
has $.easeLinearity;
has $.worldCopyJump;
has $.maxBoundsViscosity;

# keyboard navigation options
has $.keyboard;
has $.keyboardPanDelta;

# mousewheel options
has $.scrollWheelZoom;
has $.wheelDebounceTime;
has $.wheelPxPerZoomLevel;

# touch interaction options
has $.tapHold;
has $.tapTolerance;
has $.touchZoom;
has $.bounceAtZoomLimits;

# map state options
has $.crs;
# has $.center; above
# has $.zoom; above
has $.minZoom;
has $.maxZoom;
# has $.layers; # above
has $.maxBounds;
has $.renderer;

# animation options
has $.zoomAnimation;
has $.zoomAnimationThreshold;
has $.fadeAnimation;
has $.markerZoomAnimation;
has $.transform3DLimit;

multi method add-circle(Numeric $lat, Numeric $lon, Numeric $radius, %opts) {
  self.create-circle( center => [$lat, $lon], radius => $radius, |%opts );
}
multi method create-circle(*%opts is copy) {
  my $center = %opts<center>:delete or die "center is required";
  die "missing radius" unless %opts<radius>:exists;
  my $new = Map::Leaflet::Circle.new(|%opts, latlng => @$center);
  @!layers.push: $new;
  $new;
}

method add-layer($layer) {
  @!layers.push: $layer;
}



method create-div-icon(*%options) {
  my $new = Map::Leaflet::DivIcon.new(|%options);
  @!icons.push: $new;
  $new;
}

method create-geojson-layer(*%options) {
  my $new = Map::Leaflet::GeoJSON.new(|%options);
  @!layers.push: $new;
  $new;
}

method add-geojson($geojson where Str|Hash, :$style) {
  my $new = Map::Leaflet::GeoJSON.new(geojson => $geojson, style => $style);
  @!layers.push: $new;
  $new;
}

method create-icon(*%options) {
  my $new = Map::Leaflet::Icon.new(|%options);
  @!icons.push: $new;
  $new;
}

method create-marker(:@latlng, :%options) {
  my $new = Map::Leaflet::Marker.new(:@latlng, |%options);
  @!markers.push: $new;
  $new;
}

multi method add-marker($lat where Numeric|Str, $lon where Numeric|Str, $popup-text?) {
  self.create-marker(:latlng(+$lat, +$lon), options => %( :$popup-text ) );
}

multi method add-marker(
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

    my $layers-js = "";
    for @!layers -> $l {
      my $extend-bounds = "bounds.extend({ $l.name }.getBounds());";
      if $l.can('render-latlng') {
        $extend-bounds = "bounds.extend({ $l.render-latlng });";
      }
      $layers-js ~= qq:to/JS/.indent(6);
      { $l.render }
      { $l.name }.addTo(map);
      $extend-bounds
      JS
    }

    my $opts-str = self.construct-option-string(exclude =>
        set <fit-bounds width height border output-path extra-css title leaflet-version leaflet-providers-version tile-provider leaflet-css-url leaflet-js-url leaflet-providers-js-url markers icons layers>);

    my $start-pos = $!fit-bounds ?? "map.fitBounds(bounds);"
    !! "map.setView({ $!center.render }, {$!zoom});";

    qq:to/END/;
    <!DOCTYPE html>
    <html>
    <head>
        <title>{ $.title }</title>
        <link rel="stylesheet" href="{$!leaflet-css-url}" />
        <script src="{$!leaflet-js-url}"></script>
        <script src="{$!leaflet-providers-js-url}"></script>
        <style>
            { self.map-css }
            $!extra-css
        </style>
    </head>
    <body>
        <div id="map"></div>
        <script>
            var map = L.map('map', $opts-str );
            L.tileLayer.provider('{$.tile-provider}').addTo(map);
            L.control.scale().addTo(map);
            let bounds = L.latLngBounds();
$layers-js
$icons-js
$markers-js
$start-pos
        </script>
    </body>
    </html>
    END
}

method write {
  my $filename = $.output-path.IO;
  my $is-new = not $filename.e;
  $filename.spurt: self.render;
  return $is-new;
}

method show {
  my $filename = $.output-path.IO;
  self.write;
  my $cmd = $*DISTRO.is-win ?? 'start'
          !! $*DISTRO ~~ /macos/ ?? 'open'
          !! 'xdg-open';
  run <<$cmd $filename>>;
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
$map.add-marker( 40.7267, -73.9815 "Tompkins Square Park");

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

When creating layers, markers, icons, etc., methods named C<add-*> are provided
with convenient interfaces.  For more control, use the C<create-*> methods, which
pass the options to the constructor for the corresponding object.

In other words, C<create-geojson-layer(...)> is equivalent to
C<add-layer(Map::Leaflet::GeoJSON.new(...))>.

See the C<eg/> directory for more examples.

=head2 ATTRIBUTES

All of the attributes listed here L< https://leafletjs.com/reference.html#map-factory>
are available as attributes in the C<Map::Leaflet> object.  They will be passed
to the javascript constructor.  For callbacks, use a C<Pair> object -- the key
and value will be the left and right hand side of a javascript pointy block.

=head2 title

The title of the HTML page.  Defaults to 'Map'.

=head2 center

A hash with C<lat> and C<lon> keys.

=head2 zoom

The zoom level (integer).

=head2 width, height

The height and width of the map.  Defaults to 95vw and 95vh, respectively.

=head2 extra-css

Extra CSS to include in the HTML.  The default adds a border, centers the map,
and provides a class for div-icons.

=head2 tile-provider

The tile provider to use.  Defaults to 'CartoDB.Positron'.  For a complete list of providers, see L<https://leaflet-extras.github.io/leaflet-providers/preview/>.

Here are a few of the providers listed:  C<CartoDB.Positron>, C<OpenStreetMap.Mapnik>, C<Esri.WorldstreetMap>

=head2 leaflet-version, leaflet-providers-version

The version of leaflet.js and leaflet-providers.js to use.  Defaults to 1.9.4 and 1.13.0, respectively.

=head2 output-path

The filename to write the HTML to.  Defaults to 'map-leaflet-tmp.html'.

=head2 other attributes

Other attributes that are passed on to the javascript constructor include: C<preferCanvas>, C<attributionControl>, C<zoomControl>, C<closePopupOnClick>, C<boxZoom>, C<doubleClickZoom>, C<dragging>, C<zoomSnap>, C<zoomDelta>, C<trackResize>, C<inertia>, C<inertiaDeceleration>, C<inertiaMaxSpeed>, C<easeLinearity>, C<worldCopyJump>, C<maxBoundsViscosity>, C<keyboard>, C<keyboardPanDelta>, C<scrollWheelZoom>, C<wheelDebounceTime>, C<wheelPxPerZoomLevel>, C<tapHold>, C<tapTolerance>, C<touchZoom>, C<bounceAtZoomLimits>, C<crs>, C<minZoom>, C<maxZoom>, C<maxBounds>, C<renderer>, C<zoomAnimation>, C<zoomAnimationThreshold>, C<fadeAnimation>, C<markerZoomAnimation>, C<transform3DLimit>.

=head1 METHODS

=head2 new

    my $map = Map::Leaflet.new;
    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor.  If no center is specified, then bounds are computed, and
the starting view will have a zoom level and extents that fit all of
the layers that have been added.  See C<ATTRIBUTES> for more options.

=head2 add-marker

    $map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");
    $map.add-marker( 40.7128, -74.0060, "New York City");

Add a marker.  The first argument is a hash with C<lat> and C<lon> keys, and the second argument
is an optional popup text.  Or the first two arguments can be numeric for the lat + lon.
See C<create-marker> below for a more flexible way to create markers.  Returns a C<Map::Leaflet::Marker> object.

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

Returns a new C<Map::Leaflet::Marker>.

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

=head2 add-circle, create-circle

  my $circle = $map.create-circle(
      center => [40.7128, -74.0060],
      radius => 500, # meters
      color => 'red',
      fillColor => 'red',
      fillOpacity => 0.5,
  );

  $map.add-circle( 40.7128, -74.0060, 500, { color => 'red' } );

Create a circle.  Accepts all of the leaflet.js options.  See L<https://leafletjs.com/reference.html#circle>.
Returns a new C<Map::Leaflet::Circle>.

=head2 render

    spurt "map.html", $map.render;

Generate a complete HTML page for the map (including html, head, body, etc.).  Returns a string.

=head2 show

    $map.show;

Generate the HTML, write it to <$.output-path>, and open a browser to view it.

=head2 write

    $map.write;

Generate the HTML and write it to <$.output-path>.  Returns true if a new file
was created, false if the file already existed and was overwritten.

=head1 SEE ALSO

L<https://leafletjs.com/>

=head1 AUTHOR

Brian Duggan

=end pod

