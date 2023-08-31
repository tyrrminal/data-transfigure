use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Object::Pad;

class Data::Transform::Value :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  field $value :param;

  ADJUST {
    die(ref($value).' is not acceptable for Data::Transform::Value(value)') if(ref($value) && ref($value) ne 'CODE' && ref($value) ne 'Regexp');
  }

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Value->applies_to') unless(exists($params{value}));
    my $node = $params{value};
    
    return $MATCH_EXACT_VALUE if(!ref($value) && $node eq $value);
    return $MATCH_LIKE_VALUE if(ref($value) eq 'Regexp' && $node =~ /$value/);
    return $MATCH_LIKE_VALUE if(ref($value) eq 'CODE' && $value->($node)); 
    return $NO_MATCH;
  }

}

1;
