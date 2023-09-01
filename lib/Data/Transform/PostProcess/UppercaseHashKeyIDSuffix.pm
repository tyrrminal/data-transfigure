package Data::Transform::PostProcess::UppercaseHashKeyIDSuffix;
use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

use Data::Transform::PostProcess;
class Data::Transform::PostProcess::UppercaseHashKeyIDSuffix : isa(Data::Transform::PostProcess) {
  use Data::Transform qw(hk_rewrite_cb);

  sub BUILDARGS ($class) {
    $class->SUPER::BUILDARGS(
      handler => sub ($entity) {
        return hk_rewrite_cb($entity, sub ($k) {$k =~ s/Id$/ID/r});
      }
    );
  }

}

1;
