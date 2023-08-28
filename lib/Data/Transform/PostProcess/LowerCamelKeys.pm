package Data::Transform::Post::LowerCamelKeys;
use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::PostProcess;
class Data::Transform::PostProcess::LowerCamelKeys :isa(Data::Transform::PostProcess) {
  use DCS::Util::NameConversion qw(convert_hash_keys);
  use String::CamelSnakeKebab qw(lower_camel_case);

  sub BUILDARGS($class) {
    $class->SUPER::BUILDARGS(
    );
  }

}

1;
