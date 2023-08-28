use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Position :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  field $path :param(position);

  my sub wildcard_to_regex($str) {
    $str =~ s|[.]|\\.|g; 
    $str =~ s|[*]|.*|g;
    return qr/^$str$/;
  }

  method applies_to($node, $position) {
    my $rv = $NO_MATCH;
    my @paths = ref($path) eq 'ARRAY' ? $path->@* : ($path);

    foreach (@paths) {
      return $MATCH_EXACT_PATH if($position eq $_);
      my $re = wildcard_to_regex($_);
      $rv = $MATCH_WILDCARD_PATH if($position =~ $re);
    }
    return $rv;
  }
  
  method transform(@args) {
    return $self->SUPER::transform(@args);
  }

}

1;
