use v5.26;

use Object::Pad;
class Data::Transform::Default :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $MATCH_DEFAULT;
  }
  
}

1;
