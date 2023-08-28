use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::PostProcess;
class Data::Transform::PostProcess::LowerCamelKeys :isa(Data::Transform::PostProcess) {
  use Data::Transform qw(hk_rewrite_cb);
  use String::CamelSnakeKebab qw(lower_camel_case);

  sub BUILDARGS($class) {
    $class->SUPER::BUILDARGS(
      handler => sub ($entity) {
        return hk_rewrite_cb($entity, \&lower_camel_case);
      }
    );
  }

}

1;
