use Map::Leaflet::Utils;

class Map::Leaflet::Icon does LeafObject {
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

class Map::Leaflet::DivIcon is Map::Leaflet::Icon {

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
