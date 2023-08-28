use v5.26;

use Data::Transform::Type;
use Object::Pad;
class Data::Transform::Type::DateTime::Duration :isa(Data::Transform::Type) {
  ADJUST {
    $self->_set_type(qw(DateTime::Duration));
    
    $self->_set_handler(
      sub ($data) {
        return DateTime::Format::Duration::ISO8601->format_duration($data);
      }
    )
  }
}

1;
