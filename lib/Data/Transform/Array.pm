use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Array : does(Data::Transform::Base) : strict(params) {
  use Data::Transform::_Internal::Constants;

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Array->applies_to') unless (exists($params{value}));
    my $node = $params{value};

    return $MATCH_EXACT if (ref($node) eq 'ARRAY');
    return $NO_MATCH;
  }

}

1;
