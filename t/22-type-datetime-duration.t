#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use DateTime::Duration;
use Data::Transform::Type::DateTime::Duration;
use Data::Transform::Constants;

my $dt = DateTime::Duration->new(minutes => 8, seconds => 15);
my $d  = Data::Transform::Type::DateTime::Duration->new();

is($d->applies_to(value => $dt),                  $MATCH_EXACT_TYPE, 'check applies_to type (DateTime::Duration)');
is($d->applies_to(value => bless({}, 'MyClass')), $NO_MATCH,         'check applies_to (negative) type (MyClass)');

is($d->transform($dt), 'PT8M15S', 'check transform type (DateTime::Duration)');

done_testing;
