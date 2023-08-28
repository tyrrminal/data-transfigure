use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Value :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  field $value :param;

  method applies_to($node, $position) {
    return $MATCH_EXACT_VALUE if(!ref($value) && $node eq $value);
    return $MATCH_LIKE_VALUE if(ref($value) eq 'Regexp' && $node =~ /$value/);
    return $MATCH_LIKE_VALUE if(ref($value) eq 'CODE' && $value->($node)); 
    return $NO_MATCH;
  }

}

1;
