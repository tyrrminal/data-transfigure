#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform::Array;
use Data::Transform::_Internal::Constants;

like(
  dies {
    Data::Transform::Array->new(type => 'CODE', handler => sub { })
  },
  qr/^Unrecognised parameters for Data::Transform::Array constructor: 'type'/,
  "check that type cannot be supplied as a parameter"
);

my $n = Data::Transform::Array->new(handler => sub { });
is($n->applies_to(value => {}),                   $NO_MATCH,    'check that not applies_to hash');
is($n->applies_to(value => bless([], 'MyClass')), $NO_MATCH,    'check that not applies_to blessed array');
is($n->applies_to(value => []),                   $MATCH_EXACT, 'check that applies_to array');

done_testing;
