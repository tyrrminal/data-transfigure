use v5.38;
use experimental qw(class);

use Data::Transform::Type;
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
