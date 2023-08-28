use v5.26;

use Object::Pad;
class Data::Transform::Type::Nested :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  field $type :param;

  ADJUST {
    foreach my $type ($self->types()) {
      die("$type cannot be used with Data::Transform::Nested - use Data::Transform::Type") unless($type eq 'HASH' || $type eq 'ARRAY');
    }
  }

  method types() {
    return ref($type) eq 'ARRAY' ? $type->@* : ($type);
  }

  method applies_to($node, $position) {
    foreach my $t ($self->types()) {
      return $MATCH_EXACT if(ref($node) eq $t);
    }
  }
}

1;
