#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;
use Test2::Tools::Exception qw(dies);

use Data::Transform::Type::Nested;
use Data::Transform::Constants;

like( dies { Data::Transform::Type::Nested->new(type => 'CODE', handler => sub{}) } ,
    qr/^CODE cannot be used with Data::Transform::Nested - use Data::Transform::Type/,
    "check that only HASH and ARRAY area allowed"
);

my $n = Data::Transform::Type::Nested->new(type => 'HASH', handler => sub{});
is([$n->types()], ['HASH'], 'check types');
is($n->applies_to({}, '/'), $MATCH_EXACT, 'check that applies_to hash');
is($n->applies_to([], '/'), $NO_MATCH, 'check that not applies_to array');

done_testing;
