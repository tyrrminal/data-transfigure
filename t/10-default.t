#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform::Default;
use Data::Transform::Constants;

my $d = Data::Transform::Default->new(
  handler => sub ($entity) {
    return 'SCALAR';
  }
);

my $o = {
  a => 1,
  b => 2,
  c => bless({id => 3, title => 'War and Peace'}, 'MyApp::Model::Result::Book'),
};

is($d->applies_to(value => $o),      $MATCH_DEFAULT, 'default match of hash');
is($d->applies_to(value => $o->{a}), $MATCH_DEFAULT, 'default match of scalar (a => 1)');
is($d->applies_to(value => $o->{b}), $MATCH_DEFAULT, 'default match of scalar (b => 2)');
is($d->applies_to(value => $o->{c}), $MATCH_DEFAULT, 'default match of scalar (c => custom class instance)');

is($d->transform($o),      'SCALAR', 'basic default transform (hash)');
is($d->transform($o->{a}), 'SCALAR', 'basic default transform (a)');
is($d->transform($o->{b}), 'SCALAR', 'basic default transform (b)');
is($d->transform($o->{c}), 'SCALAR', 'basic default transform (c)');

$d = Data::Transform::Default->new(
  handler => sub ($entity) {
    return 'OBJECT' if (ref($entity));
    return "$entity";
  }
);

is($d->transform($o),      'OBJECT', 'deobjectifying default transform (hash)');
is($d->transform($o->{a}), "1",      'deobjectifying default transform (a)');
is($d->transform($o->{b}), "2",      'deobjectifying default transform (b)');
is($d->transform($o->{c}), 'OBJECT', 'deobjectifying default transform (c)');

done_testing;
