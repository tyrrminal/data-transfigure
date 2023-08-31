#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;
use Test2::Tools::Mock qw(mock_obj);
use Test2::Tools::Exception qw(dies);

use Data::Transform::Value;
use Data::Transform::Constants;

my $v = mock_obj();
my $v_ref = ref($v);
like(dies { Data::Transform::Value->new(value => $v, handler => sub{} ) },
  qr/^$v_ref is not acceptable for Data::Transform::Value\(value\)/,
  'check that value is of a supported type'
);

my $d = Data::Transform::Value->new(
  value => 7,
  handler => sub($entity) {
    $entity + 2
  }
);

my $o = {
  a => 1,
  b => 7,
  c => 3,
  d => 'the cat jumped over the moon'
};

is($d->applies_to($o, '/'), $NO_MATCH, 'num value applies_to (hash)');
is($d->applies_to($o->{a}, '/a'), $NO_MATCH, 'num value applies_to (1)');
is($d->applies_to($o->{b}, '/b'), $MATCH_EXACT_VALUE, 'num value applies_to (7)');
is($d->applies_to($o->{c}, '/c'), $NO_MATCH, 'num value applies_to (3)');
is($d->applies_to($o->{d}, '/d'), $NO_MATCH, 'num value applies_to (str)');

is($d->transform($o->{b}), 9, 'num value transform');

$d = Data::Transform::Value->new(
  value => qr/cat/,
  handler => sub($entity) {
    $entity =~ s/cat/dog/gr
  }
);

is($d->applies_to($o, '/'),       $NO_MATCH,          'regex value applies_to (hash)');
is($d->applies_to($o->{a}, '/a'), $NO_MATCH,          'regex value applies_to (1)');
is($d->applies_to($o->{b}, '/b'), $NO_MATCH,          'regex value applies_to (7)');
is($d->applies_to($o->{c}, '/c'), $NO_MATCH,          'regex value applies_to (3)');
is($d->applies_to($o->{d}, '/d'), $MATCH_LIKE_VALUE,  'regex value applies_to (str)');

is($d->transform($o->{d}), 'the dog jumped over the moon', 'regex value transform');

$d = Data::Transform::Value->new(
  value => sub ($v) {$v =~ /^-?\d+$/ && $v < 5 },
  handler => sub ($entity) {
    -1
  }
);

is($d->applies_to($o, '/'),       $NO_MATCH,          'code value applies_to (hash)');
is($d->applies_to($o->{a}, '/a'), $MATCH_LIKE_VALUE,  'code value applies_to (1)');
is($d->applies_to($o->{b}, '/b'), $NO_MATCH,          'code value applies_to (7)');
is($d->applies_to($o->{c}, '/c'), $MATCH_LIKE_VALUE,  'code value applies_to (3)');
is($d->applies_to($o->{d}, '/d'), $NO_MATCH,          'code value applies_to (str)');

is($d->transform($o->{a}), -1, 'regex value transform (a)');
is($d->transform($o->{c}), -1, 'regex value transform (c)');

done_testing;
