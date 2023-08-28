use v5.26;

use Object::Pad;
class Data::Transform::Undef :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $MATCH_EXACT_TYPE if(!defined($node));
    return $NO_MATCH;
  }
  
}

1;
