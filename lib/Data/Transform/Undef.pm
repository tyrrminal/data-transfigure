use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::Value;
class Data::Transform::Undef : isa(Data::Transform::Value) {
  use Data::Transform::Constants;

  sub BUILDARGS ($class, @args) {
    $class->SUPER::BUILDARGS(
      value => undef,
      @args,
    );
  }

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Undef->applies_to') unless (exists($params{value}));
    my $node = $params{value};

    return $MATCH_EXACT_TYPE if (!defined($node));
    return $NO_MATCH;
  }

}

1;
