
use lib $*HOME.child('raku-webservice-overpass/lib');

use WebService::Overpass;
use Map::Leaflet;
use JSON::Fast;

my \op = WebService::Overpass.new;

my $data = from-json(op.query: q:to/EOQ/);
  [out:json];
  (
    node(-25.38653, 130.99883, -25.31478, 131.08938)["natural"="cave_entrance"];
  );
  out;
  EOQ

my $map = Map::Leaflet.new;

for $data<elements>.list -> %e {
  $map.add-marker(%e<lat lon>:kv.Hash, %e<tags><name>);
}

spurt 'caves.html', $map.generate-page;
