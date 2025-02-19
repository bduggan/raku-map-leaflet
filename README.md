[![Actions Status](https://github.com/bduggan/raku-map-leaflet/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-map-leaflet/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-map-leaflet/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-map-leaflet/actions/workflows/macos.yml)

NAME
====

Map::Leaflet - Generate maps using leaflet.js

SYNOPSIS
========

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

![output](https://github.com/user-attachments/assets/fd0b1a5f-ec57-4007-b5dd-a5daa10c85f7)

DESCRIPTION
===========

Generate HTML that renders a map, using the excellent leaflet.js library.

The `Map::Leaflet` class represents a map which can be rendered as HTML. Use a map object to create objects which are analogous to their javascript counterparts, and then render the entire page to generate the javascript.

There are default values for many of the leaflet objects, in an attempt to make common cases work more easily out of the box.

When creating layers, markers, icons, etc., methods named `add-*` are provided with convenient interfaces. For more control, use the `create-*` methods, which pass the options to the constructor for the corresponding object.

In other words, `create-geojson-layer(...)` is equivalent to `add-layer(Map::Leaflet::GeoJSON.new(...))`.

See the `eg/` directory for more examples.

EXPORTS
-------

If an argument is given when using the module, it is treated as the name of a new object to create. e.g.

    use Map::Leaflet 'map';
    map.add-marker(40.7128, -74.0060, "New York City");

is the same as

    use Map::Leaflet 'map';
    my \map = Map::Leaflet.new;
    map.add-marker(40.7128, -74.0060, "New York City");

ATTRIBUTES
----------

All of the attributes listed here [https://leafletjs.com/reference.html#map-factory](https://leafletjs.com/reference.html#map-factory) are available as attributes in the `Map::Leaflet` object. They will be passed to the javascript constructor. For callbacks, use a `Pair` object -- the key and value will be the left and right hand side of a javascript pointy block.

title
-----

The title of the HTML page. Defaults to 'Map'.

center
------

A hash with `lat` and `lon` keys.

zoom
----

The zoom level (integer).

width, height
-------------

The height and width of the map. Defaults to 95vw and 95vh, respectively.

extra-css
---------

Extra CSS to include in the HTML. The default adds a border, centers the map, and provides a class for div-icons.

tile-provider
-------------

The tile provider to use. Defaults to 'CartoDB.Positron'. For a complete list of providers, see [https://leaflet-extras.github.io/leaflet-providers/preview/](https://leaflet-extras.github.io/leaflet-providers/preview/).

Here are a few of the providers listed: `CartoDB.Positron`, `OpenStreetMap.Mapnik`, `Esri.WorldstreetMap`

leaflet-version, leaflet-providers-version
------------------------------------------

The version of leaflet.js and leaflet-providers.js to use. Defaults to 1.9.4 and 1.13.0, respectively.

output-path
-----------

The filename to write the HTML to. Defaults to 'map-leaflet-tmp.html'.

other attributes
----------------

Other attributes that are passed on to the javascript constructor include: `preferCanvas`, `attributionControl`, `zoomControl`, `closePopupOnClick`, `boxZoom`, `doubleClickZoom`, `dragging`, `zoomSnap`, `zoomDelta`, `trackResize`, `inertia`, `inertiaDeceleration`, `inertiaMaxSpeed`, `easeLinearity`, `worldCopyJump`, `maxBoundsViscosity`, `keyboard`, `keyboardPanDelta`, `scrollWheelZoom`, `wheelDebounceTime`, `wheelPxPerZoomLevel`, `tapHold`, `tapTolerance`, `touchZoom`, `bounceAtZoomLimits`, `crs`, `minZoom`, `maxZoom`, `maxBounds`, `renderer`, `zoomAnimation`, `zoomAnimationThreshold`, `fadeAnimation`, `markerZoomAnimation`, `transform3DLimit`.

METHODS
=======

new
---

    my $map = Map::Leaflet.new;
    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor. If no center is specified, then bounds are computed, and the starting view will have a zoom level and extents that fit all of the layers that have been added. See `ATTRIBUTES` for more options.

add-marker
----------

    $map.add-marker: { :lat(40.7128), :lon(-74.0060) }, "New York City";
    $map.add-marker: 40.7128, -74.0060, "New York City";
    $map.add-marker: [40.7128, -74.0060], div => "You are here";

Add a marker. The first argument is a hash with `lat` and `lon` keys, and the second argument is an optional popup text. Or the first two arguments can be numeric for the lat + lon. Or they can be an array of two numbers. If a `div` option is provided, it will be used as the `html` option for a `create-div-icon` call, and an `icon` option will be added to the marker.

See `create-marker` below for a more complete way to create markers. Returns a `Map::Leaflet::Marker` object.

create-div-icon
---------------

    my $div-icon = $map.create-div-icon(html => '<b>New York City</b>');
    my $div-icon = $map.create-div-icon: html => '<b>Paris</b>', iconSize => 'auto', className => 'mlraku-div-icon';

Create a divIcon. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#divicon](https://leafletjs.com/reference.html#divicon). Defaults to auto-sizing, a yellow background, and a black border, and a class of 'mlraku-div-icon'.

Also accepts a `name` option, which is used to name the icon in the javascript (defaults to an auto-generated name).

Returns a `Map::Leaflet::DivIcon` object.

create-icon
-----------

    my $icon = $map.create-icon(iconUrl => 'https://leafletjs.com/examples/custom-icons/leaf-green.png');
    my $icon = $map.create-icon: iconUrl => 'https://leafletjs.com/examples/custom-icons/leaf-green.png', iconSize => '[38, 95]';

Create an icon. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#icon](https://leafletjs.com/reference.html#icon). Note that the iconSize, iconAnchor, popupAnchor, and tooltipAnchor are all `PointStr` objects, which can be either a string of the form "[x, y]" or the string "auto".

create-marker
-------------

    $map.create-marker(latlng => [ $lat, $lon ], options => %( icon => $icon ));
    $map.create-marker: latlng => [ $lat, $lon ], options => %( title => 'New York City', popup-text => 'The Big Apple' );

Create a marker. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#marker](https://leafletjs.com/reference.html#marker). Also accepts popup-text as an option to generate a popup that is bound to the marker.

Defaults to False values for autoPan and autoPanFocus.

Returns a new `Map::Leaflet::Marker`.

add-geojson
-----------

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

Add a GeoJSON layer. `$geojson` can be a string or a hash. `$style` is optional and can also be a string or a hash.

add-circle, create-circle
-------------------------

    my $circle = $map.create-circle(
        center => [40.7128, -74.0060],
        radius => 500, # meters
        color => 'red',
        fillColor => 'red',
        fillOpacity => 0.5,
    );

    $map.add-circle( 40.7128, -74.0060, 500, { color => 'red' } );

Create a circle. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#circle](https://leafletjs.com/reference.html#circle). Returns a new `Map::Leaflet::Circle`.

add-rectangle, create-rectangle
-------------------------------

    $map.add-rectangle(40.7128, -74.0060, 40.7589, -73.9851, color => 'red');
    $map.add-rectangle([40.7128, -74.0060, 40.7589, -73.9851], color => 'red');
    $map.add-rectangle([ [40.7128, -74.0060], [40.7589, -73.9851]], color => 'red');

    my $rectangle = $map.create-rectangle(
        bounds => [[40.7128, -74.0060], [40.7589, -73.9851]],
        color => 'red',
        fillColor => 'red',
        fillOpacity => 0.5,
    );

Create a rectangle. The bounds can be specified either as four separate coordinates (lat1, lon1, lat2, lon2) or as an array of four numbers. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#rectangle](https://leafletjs.com/reference.html#rectangle). Returns a new `Map::Leaflet::Rectangle`.

add-polygon, create-polygon
---------------------------

    my $polygon = $map.create-polygon(
        latlngs => [
            [40.7128, -74.0060],
            [40.7589, -73.9851],
            [40.7267, -73.9815]
        ],
        color => 'blue',
        fillColor => 'blue',
        fillOpacity => 0.3,
    );

    $map.add-polygon(latlngs => [[40.7128, -74.0060], [40.7589, -73.9851], [40.7267, -73.9815]]);

Create a polygon. The `latlngs` parameter is required and should be an array of coordinate pairs. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#polygon](https://leafletjs.com/reference.html#polygon). Returns a new `Map::Leaflet::Polygon`.

add-polyline, create-polyline
-----------------------------

    my $polyline = $map.create-polyline(
        latlngs => [
            [40.7128, -74.0060],
            [40.7589, -73.9851]
        ],
        color => 'red',
        weight => 3,
    );

    $map.add-polyline(latlngs => [[40.7128, -74.0060], [40.7589, -73.9851]]);

Create a polyline. The `latlngs` parameter is required and should be an array of coordinate pairs. Accepts all of the leaflet.js options. See [https://leafletjs.com/reference.html#polyline](https://leafletjs.com/reference.html#polyline). Returns a new `Map::Leaflet::Polyline`.

add-icons, add-markers
----------------------

These exist if you create icons or markers without using the `create-*` methods. They will add the objects to the map. For examples, see `Map::Leaflet::Icon`

render
------

    spurt "map.html", $map.render;

Generate a complete HTML page for the map (including html, head, body, etc.). Returns a string.

show
----

    $map.show;

Generate the HTML, write it to <$.output-path>, and open a browser to view it.

write
-----

    $map.write;

Generate the HTML and write it to <$.output-path>. Returns true if a new file was created, false if the file already existed and was overwritten.

SEE ALSO
========

[https://leafletjs.com/](https://leafletjs.com/)

AUTHOR
======

Brian Duggan

