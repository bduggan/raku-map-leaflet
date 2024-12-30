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

![output](https://github.com/user-attachments/assets/fd0b1a5f-ec57-4007-b5dd-a5daa10c85f7)

DESCRIPTION
===========

Generate HTML that renders a map, using the excellent leaflet.js library.

METHODS
=======

new
---

    my $map = Map::Leaflet.new;
    my $map = Map::Leaflet.new(
        center => { :lat(40.7128), :lon(-74.0060) },
        zoom => 13
    );

Constructor. If no center is specified, then it will fit the bounds of all markers and geojson layers.

Other options are:

#### title

The title of the HTML page. Defaults to 'Map'.

#### center

A hash with `lat` and `lon` keys.

#### zoom

The zoom level (integer).

#### width, height

The height and width of the map. Defaults to 95vw and 95vh, respectively.

#### extra-css

Extra CSS to include in the HTML. The default adds a border and centers the map.

#### tile-provider

The tile provider to use. Defaults to 'CartoDB.Positron'. For a complete list of providers, see [https://leaflet-extras.github.io/leaflet-providers/preview/](https://leaflet-extras.github.io/leaflet-providers/preview/).

Here are a few of the providers listed: `CartoDB.Positron`, `OpenStreetMap.Mapnik`, `Esri.WorldstreetMap`

#### leaflet-version, leaflet-providers-version

The version of leaflet.js and leaflet-providers.js to use. Defaults to 1.9.4 and 1.13.0, respectively.

add-marker
----------

    $map.add-marker({ :lat(40.7128), :lon(-74.0060) }, "New York City");

Add a marker. The first argument is a hash with `lat` and `lon` keys, and the second argument is an optional popup text.

add-geojson
-----------

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

Add a GeoJSON layer. The argument is a string containing GeoJSON.

generate-page
-------------

    spurt "map.html", $map.generate-page;

Generate a complete HTML page for the map (including html, head, body, etc.). Returns a string.

SEE ALSO
========

[https://leafletjs.com/](https://leafletjs.com/)

AUTHOR
======

Brian Duggan

