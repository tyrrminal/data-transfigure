use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Base {
  use Data::Transform::_Internal::Constants;

  field $handler : param;

  method applies_to(%params) {
    return $NO_MATCH;
  }

  method transform(@args) {
    return $handler->(@args)
  }
}

1;
