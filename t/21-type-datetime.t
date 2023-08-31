#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use DateTime;
use Data::Transform::Type::DateTime;
use Data::Transform::_Internal::Constants;

my $dt = DateTime->new(year => 2000, month => 1, day => 1);
my $d  = Data::Transform::Type::DateTime->new();

is($d->applies_to(value => $dt),                  $MATCH_EXACT_TYPE, 'check applies_to type (DateTime)');
is($d->applies_to(value => bless({}, 'MyClass')), $NO_MATCH,         'check applies_to (negative) type (MyClass)');

is($d->transform($dt), '2000-01-01T00:00:00', 'check transform type (DateTime)');

done_testing;
