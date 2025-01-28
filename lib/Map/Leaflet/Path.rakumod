#!raku

=begin pod

=head1 NAME

Map::Leaflet::Path - Base class for all path objects

=head1 SYNOPSIS

  use Map::Leaflet;
  use Map::Leaflet::Path;

  my $map = Map::Leaflet.new;
  my $circle = Map::Leaflet::Circle.new(
    latlng => [51.505, -0.09],
    radius => 500
  );
  $map.add($circle);

=head1 DESCRIPTION

This is the base class for Path objects.

  https://leafletjs.com/reference.html#path

It is not intended to be used directly, but to be subclassed by other classes.

=head1 SUBCLASSES

=item L<Map::Leaflet::Circle>

=item L<Map::Leaflet::Polygon>

=item L<Map::Leaflet::Polyline>

=item L<Map::Leaflet::Rectangle>

=end pod

use Map::Leaflet::Utils;
use Map::Leaflet::Layer;

my $i = 0;

class Map::Leaflet::Path is Map::Leaflet::InteractiveLayer is export {

  also does LeafObject;
  has $.name = 'path_' ~ $i++;
  has $.stroke;
  has $.color;
  has $.weight;
  has $.lineCap;
  has $.lineJoin;
  has $.dashArray;
  has $.dashOffset;
  has $.fill;
  has $.fillColor;
  has $.fillOpacity;
  has $.fillRule;
  has $.bubblingMouseEvents;
  has $.renderer;
  has $.className;
  method render {
    my $opts-str = self.construct-option-string;
    return Q:s:to/JS/;
      let $.name = L.Path($opts-str)
    JS
  }
}

class Map::Leaflet::Circle is Map::Leaflet::Path is export {
  has $.name = 'circle_' ~ $i++;
  has Numeric @.latlng;
  has Numeric $.radius;
  method render {
    my $opts-str = self.construct-option-string(exclude => set <latlng>);
    my $latlng = '[' ~ @.latlng.join(',') ~ ']';
    return Q:s:to/JS/;
      let $.name = L.circle( $latlng, $opts-str)
    JS
  }
}

class Map::Leaflet::Polygon is Map::Leaflet::Path is export {
  also does LeafObject;
  has $.name = 'polygon_' ~ ++$i;
  # [[lat1, lon1], [lat2, lon2], ...]
  has @.latlngs;
  submethod TWEAK {
    die "polygon coordinates must have two elements" if @!latlngs[0].elems != 2;
  }

  method render {
    my $latlngs = '['~
      @.latlngs.map({ '['~.[0]~','~.[1]~']' }).join(',')
      ~ ']';
    my $opts-str = self.construct-option-string(exclude => set <latlngs>);
    my $js = qq:to/JS/;
      let $.name = L.polygon([$latlngs], $opts-str);
    JS
    $js;
  }
}

class Map::Leaflet::Polyline is Map::Leaflet::Path is export {
  also does LeafObject;
  has $.name = 'polyline_' ~ ++$i;
  has @.latlngs;
  has Numeric $.smoothFactor;
  has Bool $.noClip;

  method render {
    my $latlngs = '['~
      @.latlngs.map({ '['~.[0]~','~.[1]~']' }).join(',')
      ~ ']';
    my $opts-str = self.construct-option-string(exclude => set <latlngs>);
    my $js = qq:to/JS/;
      let $.name = L.polyline([$latlngs], $opts-str);
    JS
    $js;
  }
}

class Map::Leaflet::Rectangle is Map::Leaflet::Polyline is export {
  also does LeafObject;
  has $.name = 'rectangle_' ~ ++$i;
  has @.bounds; # [[lat1, lon1], [lat2, lon2]]

  method TWEAK {
    die "rectangle bounds must have two elements" if @!bounds[0].elems != 2;
    @!bounds = @!bounds.map({ [ +.[0], +.[1]] });
  }

  method render {
    my $bounds = @.bounds.raku;
    my $opts-str = self.construct-option-string(exclude => set <bounds>);
    my $js = qq:to/JS/;
      let $.name = L.rectangle([$bounds], $opts-str);
    JS
    $js;
  }
}
