package Data::Transform::Constants;
use v5.26;
use warnings;
# ABSTRACT: turns baubles into trinkets

use Exporter qw(import);
use Readonly;

our @EXPORT = qw(
  $PATH_SEPARATOR

  $NO_MATCH
  $MATCH_DEFAULT
  $MATCH_INHERITED_TYPE
  $MATCH_EXACT_TYPE
  $MATCH_LIKE_VALUE
  $MATCH_EXACT_VALUE
  $MATCH_WILDCARD_POSITION
  $MATCH_EXACT_POSITION
  $MATCH_CORE_REF_TYPE
  $MATCH_EXACT
);

Readonly::Scalar our $PATH_SEPARATOR => q{/};

Readonly::Scalar our $NO_MATCH                 => 0;
Readonly::Scalar our $MATCH_DEFAULT            => 1;
Readonly::Scalar our $MATCH_INHERITED_TYPE     => 2;
Readonly::Scalar our $MATCH_EXACT_TYPE         => 3;
Readonly::Scalar our $MATCH_LIKE_VALUE         => 4;
Readonly::Scalar our $MATCH_EXACT_VALUE        => 5;
Readonly::Scalar our $MATCH_WILDCARD_POSITION  => 6;
Readonly::Scalar our $MATCH_EXACT_POSITION     => 7;
Readonly::Scalar our $MATCH_CORE_REF_TYPE      => 8;
Readonly::Scalar our $MATCH_EXACT              => 100;

1;
