use Map::Leaflet::Utils;
use Map::Leaflet::Icon;
use Map::Leaflet::InteractiveLayer;

class Map::Leaflet::Marker is Map::Leaflet::InteractiveLayer does LeafObject {
  my $index = 0;
  has $.name = 'marker_' ~ ($index++);
  has $.popup-text;
  has Numeric @.latlng;

  has Map::Leaflet::Icon $.icon;
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
