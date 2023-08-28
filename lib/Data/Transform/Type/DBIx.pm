use v5.38;
use experimental qw(class);

use Data::Transform::Type;
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
