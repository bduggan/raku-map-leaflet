
use lib $*HOME.child('raku-webservice-overpass/lib');

use WebService::Overpass;
use Map::Leaflet;
use JSON::Fast;

# see https://osm-queries.ldodds.com/tutorial/05-nodes-combined-filter.osm.html

my \op = WebService::Overpass.new;
my $map = Map::Leaflet.new(tile-provider => 'Esri.WorldImagery');

my $data = from-json(op.query: q:to/EOQ/);
  [out:json];
  node(-25.38653, 130.99883, -25.31478, 131.08938)["natural"="cave_entrance"];
  out;
  EOQ

my $url = 'https://www.svgrepo.com/download/145027/cave.svg';

my $cave-icon = $map.create-icon(iconUrl => $url, iconSize => '[32, 32]');

for $data<elements>.list -> %e {
  my $label = %e<tags><name> // 'Cave';
  my $div-icon = $map.create-div-icon(html => $label);
  $map.create-marker(latlng => [ %e<lat>, %e<lon>], options => %( icon => $cave-icon ));
  my $m2 = $map.create-marker:
     latlng => [ %e<lat>, %e<lon>],
     options => %( icon => $div-icon,
         popup-text => %e<tags>.sort.map({ '<b>' ~ .key ~ '</b>: ' ~ .value }).join("<br>\n")
       );
}


spurt 'caves.html', $map.render;

# shell "firefox ./caves.html";

