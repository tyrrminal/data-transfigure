use v5.26;

use Data::Transform::Type;
use Object::Pad;
class Data::Transform::Type::DateTime :isa(Data::Transform::Type) {
  ADJUST {
    $self->_set_type(qw(DateTime));

    $self->_set_handler(
      sub ($data) {
        return $data->iso8601;
      }
    )
  }
}

1;
