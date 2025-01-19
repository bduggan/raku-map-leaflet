use Map::Leaflet::Utils;
use JSON::Fast;

my $i;

class Map::Leaflet::Layer {
  has $.attribution;
}

class Map::Leaflet::InteractiveLayer is Map::Leaflet::Layer {
  has Bool $.interactive;
}

class Map::Leaflet::GeoJSON is Map::Leaflet::InteractiveLayer {
  also does LeafObject;
  has $.name = 'geojson_' ~ ++$i;
  has $.geojson where Str|Hash;
  has $.pointToLayer;
  has $.style;
  has $.onEachFeature;
  has $.filter;
  has $.coordsToLatLng;
  has $.markersInheritOptions;

  method render {
    my $opts-str = self.construct-option-string(exclude => set <geojson>);
    my $geojson = $.geojson ~~ Str ?? $.geojson !! to-json($.geojson, :!pretty);
    my $js = qq:to/JS/;
      let {$.name} = L.geoJson($geojson, $opts-str);
    JS
    $js;
  }
}


