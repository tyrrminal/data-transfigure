use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::Type;
class Data::Transform::Type::DBIx::Recursive : isa(Data::Transform::Type) {

  sub BUILDARGS ($class) {
    $class->SUPER::BUILDARGS(
      type    => q(DBIx::Class::Row),
      handler => sub ($data) {
        my %cols = $data->get_inflated_columns;
        foreach my $rel ($data->result_source->relationships) {
          my $info = $data->result_source->relationship_info($rel);
          if ($info->{attrs}->{accessor} eq 'single') {
            delete(@cols{keys($info->{attrs}->{fk_columns}->%*)});
            $cols{$rel} = $data->$rel;
          }
        }
        return {%cols};
      }
    );
  }

}

1;
