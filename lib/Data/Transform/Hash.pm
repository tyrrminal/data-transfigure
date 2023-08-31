use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Hash :isa(Data::Transform::Base) :strict(params) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $MATCH_EXACT if(ref($node) eq 'HASH');
    return $NO_MATCH;
  }

}

1;
