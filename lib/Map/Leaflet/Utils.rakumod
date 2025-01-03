unit module Map::Leaflet::Utils;

subset PointStr of Str is export where { $_ eq 'auto' or /:s ^ '[' \d+ ',' \d+ ']' $/ };

sub escape-val(Str $val) is export {
  $val.subst(:g,  / "'" /, "\\'").subst(:g, "\n", "\\n");
}

sub quote-value($value) is export {
  given $value {
    when PointStr { $value eq 'auto' ?? "'auto'" !! $value }
    when Str { "'" ~ escape-val($value) ~ "'" }
    when Bool { $value ?? 'true' !! 'false' }
    default { $value.Str }
  }
}

sub option-string(%options) is export {
  '{' ~
  %options.map({ .key ~ ': ' ~ quote-value(.value) }).join(', ')
  ~ '}';
}

role LeafObject is export {
  method construct-options(Set :$exclude) {
    my %values;
    for self.^attributes.list -> $attr {
      my $value = $attr.get_value(self);
      next unless defined($value);
      # remove sigil
      my $key = $attr.name.subst( / <-[a..zA..Z0..9-]>+ /, '', :g );
      next if $key eq 'name';
      next if $exclude && $key (elem) $exclude;
      %values{ $key } = $value;
    }
    return %values;
  }

  method construct-option-string(Set :$exclude) {
    my %values = self.construct-options(:$exclude);
    return option-string(%values);
  }

  method Str { $.name }
}
