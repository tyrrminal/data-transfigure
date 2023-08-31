#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;
use Test2::Tools::Exception qw(dies);

use Data::Transform::Type;
use Data::Transform::Constants;

like(dies { Data::Transform::Type->new(type => 'HASH', handler => sub{}) },
  qr/^HASH cannot be used with Data::Transform::Type - use Data::Transform::Hash/,
  'check that HASH is not allowed'
);
like(dies { Data::Transform::Type->new(type => 'ARRAY', handler => sub{}) },
  qr/^ARRAY cannot be used with Data::Transform::Type - use Data::Transform::Array/,
  'check that ARRAY is not allowed'
);

my $d = Data::Transform::Type->new(
  type => 'MyTestClass',
  handler => sub{}
);

is([$d->types()], ['MyTestClass'], 'check single type');

$d = Data::Transform::Type->new(
  type => [qw(DateTime DateTime::Duration DBIx::Class::Row)],
  handler => sub{}
);

is([$d->types()], ['DateTime', 'DateTime::Duration', 'DBIx::Class::Row'], 'check multi types');

my $class = 'MyApp::Model::Result::Person';
my $person = bless({ id => 3, name => 'bob'}, $class);

$d = Data::Transform::Type->new(
  type => $class,
  handler => sub ($entity) {
    return {name => $entity->{name} }
  }
);

my $o = {
  a => 1,
  b => $person,
  c => [qw(d e f)],
};

is($d->applies_to(value => $o),      $NO_MATCH,         'check type applies_to (hash)');
is($d->applies_to(value => $o->{a}), $NO_MATCH,         'check type applies_to (num)');
is($d->applies_to(value => $o->{b}), $MATCH_EXACT_TYPE, 'check type applies_to (person obj)');
is($d->applies_to(value => $o->{c}), $NO_MATCH,         'check type applies_to (array)');

is($d->transform($o->{b}), {name => 'bob'}, 'basic base transform');

done_testing;
