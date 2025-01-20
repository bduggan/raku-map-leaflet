NAME
====

Map::Leaflet::Icon - Leaflet Icon class 

SYNOPSIS
========

    use Map::Leaflet;

    my $icon = Map::Leaflet::Icon.new(
      iconUrl => 'https://wikipedia.org/favicon.ico',
      iconSize => '[32, 32]',
      iconAnchor => '[16, 16]',
      popupAnchor => '[0, -16]',
    );

    my $div_icon = Map::Leaflet::DivIcon.new(
      html => '<div>My Icon</div>',
      iconSize => '[32, 32]',
      iconAnchor => '[16, 16]',
      popupAnchor => '[0, -16]',
    );

    my $marker = Map::Leaflet::Marker.new(
      latlng => [51.5, -0.09],
      icon => $icon,
    );

    my $marker2 = Map::Leaflet::Marker.new(
     latlng => [51.52, -0.09],
     icon => $div_icon,
    );

    my $map = Map::Leaflet.new(
      center => [51.505, -0.09],
      zoom => 13,
    );

    $map.add-icons($icon, $div_icon);
    $map.add-markers($marker, $marker2);
    $map.show;

DESCRIPTION
===========

This module provides a class for creating Leaflet icons. The attributes of the class are based on the options available in the Leaflet Icon class. For details, see the Leaflet documentation: [https://leafletjs.com/reference-1.7.1.html#icon](https://leafletjs.com/reference-1.7.1.html#icon)

They can be added as shown above, or you can use `create-icon` method of the `Map::Leaflet` class.

NAME
====

Map::Leaflet::DivIcon - Leaflet DivIcon class

SYNOPSIS
========

    use Map::Leaflet;
    use Map::Leaflet::DivIcon;

    my $div_icon = Map::Leaflet::DivIcon.new(
      html => '<div>My Icon</div>',
      iconSize => [32, 32],
      iconAnchor => [16, 16],
      popupAnchor => [0, -16],
    );

    my $map = Map::Leaflet.new(
      center => [51.505, -0.09],
      zoom => 13,
      layers => [$div_icon],
    );

    $map.render;

DESCRIPTION
===========

This module provides a class for creating Leaflet div icons.

The attributes of the class are based on the options available in the Leaflet DivIcon class.

For details, see the Leaflet documentation: [https://leafletjs.com/reference-1.7.1.html#divicon](https://leafletjs.com/reference-1.7.1.html#divicon)

