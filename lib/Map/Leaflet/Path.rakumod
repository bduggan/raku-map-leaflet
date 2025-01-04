#!raku

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
