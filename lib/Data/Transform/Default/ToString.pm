package Data::Transform::Default::ToString;
use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Default::ToString : isa(Data::Transform::Default) {
  
  sub BUILDARGS($class) {
    $class->SUPER::BUILDARGS(
      handler => sub($value) {
        return "$value"
      }
    )
  }

}

1;
