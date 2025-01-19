NAME
====

Map::Leaflet::Path - Base class for all path objects

SYNOPSIS
========

    use Map::Leaflet;
    use Map::Leaflet::Path;

    my $map = Map::Leaflet.new;
    my $circle = Map::Leaflet::Circle.new(
      latlng => [51.505, -0.09],
      radius => 500
    );
    $map.add($circle);

DESCRIPTION
===========

This is the base class for Path objects.

    https://leafletjs.com/reference.html#path

It is not intended to be used directly, but to be subclassed by other classes.

SUBCLASSES
==========

  * [Map::Leaflet::Circle](Map::Leaflet::Circle)

  * [Map::Leaflet::Polygon](Map::Leaflet::Polygon)

  * [Map::Leaflet::Polyline](Map::Leaflet::Polyline)

  * [Map::Leaflet::Rectangle](Map::Leaflet::Rectangle)

