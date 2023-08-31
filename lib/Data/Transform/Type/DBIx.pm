use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::Type;
class Data::Transform::Type::DBIx : isa(Data::Transform::Type) {

  sub BUILDARGS ($class) {
    $class->SUPER::BUILDARGS(
      type    => qw(DBIx::Class::Row),
      handler => sub ($data) {
        return {$data->get_inflated_columns};
      }
    );
  }

}

1;
