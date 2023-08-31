use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Hash : does(Data::Transform::Base) : strict(params) {
  use Data::Transform::_Internal::Constants;

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Hash->applies_to') unless (exists($params{value}));
    my $node = $params{value};

    return $MATCH_EXACT if (ref($node) eq 'HASH');
    return $NO_MATCH;
  }

}

1;
