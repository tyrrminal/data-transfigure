#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform::Undef;
use Data::Transform::Constants;

my $d = Data::Transform::Undef->new(
  handler => sub($entity) {
    return "__UNDEF__"
  }
);

my $o = {
  a => 1,
  b => undef,
  c => "3",
};

is($d->applies_to(value => $o), $NO_MATCH, 'check undef applies_to (hash)');
is($d->applies_to(value => $o->{a}), $NO_MATCH, 'check undef applies_to (num)');
is($d->applies_to(value => $o->{b}), $MATCH_EXACT_TYPE, 'check undef applies_to (undef)');
is($d->applies_to(value => $o->{c}), $NO_MATCH, 'check undef applies_to (str)');

is($d->transform($o), '__UNDEF__', 'transform undef (hash)');
is($d->transform($o->{a}), '__UNDEF__', 'transform undef (num)');
is($d->transform($o->{b}), '__UNDEF__', 'transform undef (undef)');
is($d->transform($o->{c}), '__UNDEF__', 'transform undef (str)');

done_testing;
