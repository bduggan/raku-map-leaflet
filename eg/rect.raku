use WebService::Nominatim;
use Map::Leaflet;

my \nom = WebService::Nominatim.new;
my \map = Map::Leaflet.new;

my $name = "Université Libre de Bruxelles";
for nom.search: $name {
  map.add-marker: .<lat lon>;
  map.add-rectangle: .<boundingbox>[0,2,1,3];
}

map.show;
