use v5.26;

use Data::Transform::Type;
use Object::Pad;
class Data::Transform::Type::DBIx::Recursive :isa(Data::Transform::Type) {

  ADJUST {
    $self->_set_type('DBIx::Class::Row');

    $self->_set_handler(sub ($data) {
      my %cols = $data->get_inflated_columns;
      foreach my $rel ($data->result_source->relationships) {
        my $info = $data->result_source->relationship_info($rel);
        if($info->{attrs}->{accessor} eq 'single') {
          delete(@cols{keys($info->{attrs}->{fk_columns}->%*)});
          $cols{$rel} = $data->$rel;
        }
      }
      return {%cols};
    });
  }

}

1;
