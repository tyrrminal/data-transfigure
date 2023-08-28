use v5.26;

use Data::Transform::PostProcess;
use Object::Pad;
class Data::Transform::PostProcess::EndsInID :isa(Data::Transform::PostProcess) {
  use DCS::Util::NameConversion qw(convert_hash_keys);

  ADJUST {
    $self->_set_handler(sub ($entity) {
      return $entity unless (ref($entity) eq 'HASH');
      return {convert_hash_keys($entity->%*, sub($k){ $k =~ s/Id$/ID/r })};
    });
  }
}

1;
