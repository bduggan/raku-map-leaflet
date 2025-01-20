=begin pod

=head1 NAME

Map::Leaflet::Icon - Leaflet Icon class 

=head1 SYNOPSIS

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
       
=head1 DESCRIPTION

This module provides a class for creating Leaflet icons.
The attributes of the class are based on the options available in the Leaflet Icon class.
For details, see the Leaflet documentation: L<https://leafletjs.com/reference-1.7.1.html#icon>

They can be added as shown above, or you can use C<create-icon> method of the C<Map::Leaflet> class.

=end pod

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

=begin pod

=head1 NAME

Map::Leaflet::DivIcon - Leaflet DivIcon class

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This module provides a class for creating Leaflet div icons.

The attributes of the class are based on the options available in the Leaflet DivIcon class.

For details, see the Leaflet documentation: L<https://leafletjs.com/reference-1.7.1.html#divicon>

=end pod

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
