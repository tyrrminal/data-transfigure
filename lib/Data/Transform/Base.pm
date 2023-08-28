use v5.26;

use Object::Pad;
class Data::Transform::Base {
  use Data::Transform::Constants;

  field $handler :param //= undef;

  method _set_handler($h) { $handler = $h }

  method applies_to($node, $position) {
    return $NO_MATCH;
  }

  method transform(@args) {
    say STDERR ref($self) unless(defined($handler));
    return $handler->(@args)
  }
}

1;
