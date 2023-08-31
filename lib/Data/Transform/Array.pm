use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Array :isa(Data::Transform::Base) :strict(params) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $MATCH_EXACT if(ref($node) eq 'ARRAY');
    return $NO_MATCH;
  }

}

1;
