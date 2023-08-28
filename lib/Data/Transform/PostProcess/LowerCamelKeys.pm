package Data::Transform::Post::LowerCamelKeys;
use v5.38;
use experimental qw(class);

use Data::Transform::PostProcess;
class Data::Transform::PostProcess::LowerCamelKeys :isa(Data::Transform::PostProcess) {
  use DCS::Util::NameConversion qw(convert_hash_keys);
  use String::CamelSnakeKebab qw(lower_camel_case);

  ADJUST {
    $self->_set_handler(sub ($entity) {
      return $entity unless (ref($entity) eq 'HASH');
      return {convert_hash_keys($entity->%*, \&lower_camel_case)};
    })
  }

}
