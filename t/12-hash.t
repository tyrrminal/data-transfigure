#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform::Hash;
use Data::Transform::Constants;

like( dies { Data::Transform::Hash->new(type => 'Regexp', handler => sub{}) } ,
    qr/^Unrecognised parameters for Data::Transform::Hash constructor: 'type'/,
    "check that type cannot be supplied as a parameter"
);

my $n = Data::Transform::Hash->new(handler => sub{});
is($n->applies_to([], '/'), $NO_MATCH, 'check that not applies_to hash');
is($n->applies_to(bless({}, 'MyClass'), '/'), $NO_MATCH, 'check that not applies_to blessed hash');
is($n->applies_to({}, '/'), $MATCH_EXACT, 'check that applies_to array');

done_testing;
