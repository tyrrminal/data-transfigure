use v5.38;
use experimental qw(class);

class Data::Transform::Path :isa(Data::Transform::Base) {
  use Data::Transform::Constants;

  field $path :param;

  my sub wildcard_to_regex($str) {
    $str =~ s|[.]|\\.|g 
    $str =~ s|[*]|.*|g;
    return qr/$str/;
  }

  method applies_to($node, $position) {
    my $rv = $NO_MATCH;
    my @paths = ref($path) eq 'ARRAY' ? $path->@* : ($path);

    foreach (@paths) {
      return $MATCH_EXACT_PATH if($position eq $_);
      my $re = wildcard_to_regex($_);
      $rv = $MATCH_WILDCARD_PATH if($position =~ $re);
    }
    return $rv;
  }
}
