use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::Type;
class Data::Transform::Type::DateTime::Duration :isa(Data::Transform::Type) {

  sub BUILDARGS($class) {
    $class->SUPER::BUILDARGS(
      type => q(DateTime::Duration),
      handler => sub ($data) {
        return DateTime::Format::Duration::ISO8601->format_duration($data);
      }
    );
  }

}

1;
