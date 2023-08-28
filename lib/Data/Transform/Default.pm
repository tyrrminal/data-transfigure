use v5.38;
use experimental qw(class);

class Data::Transform::Default :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $MATCH_DEFAULT;
  }
  
}
