use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

role Data::Transform::Base {
  field $handler : param;

  method applies_to;

  method transform(@args) {
    return $handler->(@args)
  }
}

1;
