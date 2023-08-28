use v5.38;
use experimental qw(class);

use Data::Transform::PostProcess;
class Data::Transform::PostProcess::EndsInID :isa(Data::Transform::PostProcess) {
  use DCS::Util::NameConversion qw(convert_hash_keys);

  ADJUST {
    $self->_set_handler(sub ($entity) {
      return $entity unless (ref($entity) eq 'HASH');
      return {convert_hash_keys($entity->%*, sub($k){ $k =~ s/Id$/ID/r })};
    });
  }
}
