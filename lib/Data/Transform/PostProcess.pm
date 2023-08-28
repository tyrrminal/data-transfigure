use v5.26;

use Object::Pad;
class Data::Transform::PostProcess :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $position eq $PATH_SEPARATOR;
  }
}

1;
