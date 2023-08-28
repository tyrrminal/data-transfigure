use v5.26;

use Data::Transform::Type;
use Object::Pad;
class Data::Transform::Type::DBIx :isa(Data::Transform::Type) {
  ADJUST {
    $self->_set_type(qw(DBIx::Class::Row));

    $self->_set_handler(
      sub ($data) {
        return {$data->get_inflated_columns};
      }
    )
  }
}

1;
