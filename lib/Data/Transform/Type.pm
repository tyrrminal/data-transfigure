use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Type : isa(Data::Transform::Base) {
  use Data::Transform::_Internal::Constants;

  use Scalar::Util qw(blessed);

  field $type : param;

  ADJUST {
    foreach my $t (grep {defined} $self->types()) {
      die("$t cannot be used with Data::Transform::Type - use Data::Transform::" . ucfirst(lc($t)))
        if ($t eq 'ARRAY' || $t eq 'HASH');
    }
  }

  method types() {
    return ref($type) eq 'ARRAY' ? $type->@* : $type;
  }

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Type->applies_to') unless (exists($params{value}));
    my $node = $params{value};

    my $rv = $NO_MATCH;
    if (my $r = ref($node)) {
      foreach ($self->types()) {
        return $MATCH_EXACT_TYPE    if ($r eq $_);
        $rv = $MATCH_INHERITED_TYPE if (blessed($node) && $node->isa($_));
      }
    }
    return $rv;
  }

}

1;
