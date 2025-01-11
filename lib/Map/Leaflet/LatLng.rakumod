unit class Map::Leaflet::LatLng;

has $.lat;
has $.lng;
method lon { $!lng }

method Str {
  self.render;
}

method render {
    return "[ $.lat, $.lng ]";
}

