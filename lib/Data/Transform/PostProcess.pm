package Data::Transform::PostProcess;
use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::PostProcess : does(Data::Transform::Base) {
  use Data::Transform::_Internal::Constants;

  method applies_to(%params) {
    return $MATCH_EXACT_POSITION;
  }

}

1;
