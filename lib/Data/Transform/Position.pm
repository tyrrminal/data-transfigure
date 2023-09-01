use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Position : does(Data::Transform::Base) {
  use Data::Transform::_Internal::Constants;

  field $position : param;
  field $transformer :param;

  my sub wildcard_to_regex ($str) {
    $str =~ s|[.]|\\.|g;
    $str =~ s|[*]|.*|g;
    return qr/^$str$/;
  }

  sub BUILDARGS($class, %params) {
    $class->SUPER::BUILDARGS(
      position => $params{position},
      transformer => $params{transformer},
      handler => sub(@args) { 
        $params{transformer}->transform(@args)
      }
    );
  }

  method applies_to(%params) {
    die('position is a required parameter for Data::Transform::Position->applies_to') unless (exists($params{position}));
    my $loc = $params{position};

    my $rv    = $NO_MATCH;
    return $rv if($transformer->applies_to(%params) == $NO_MATCH);
    my @paths = ref($position) eq 'ARRAY' ? $position->@* : ($position);

    foreach (@paths) {
      return $MATCH_EXACT_POSITION if ($loc eq $_);
      my $re = wildcard_to_regex($_);
      $rv = $MATCH_WILDCARD_POSITION if ($loc =~ $re);
    }
    return $rv;
  }

}

1;
