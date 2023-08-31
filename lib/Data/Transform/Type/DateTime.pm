use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::Type;
class Data::Transform::Type::DateTime : isa(Data::Transform::Type) {

  sub BUILDARGS ($class) {
    $class->SUPER::BUILDARGS(
      type    => q(DateTime),
      handler => sub ($data) {
        return $data->iso8601;
      }
    );
  }

}

1;
