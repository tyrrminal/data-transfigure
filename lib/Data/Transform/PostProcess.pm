use v5.38;
use experimental qw(class);

class Data::Transform::PostProcess :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  method applies_to($node, $position) {
    return $position eq $PATH_SEPARATOR;
  }
}
