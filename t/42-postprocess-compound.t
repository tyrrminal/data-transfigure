#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform;

my $t1 = Data::Transform->new();
$t1->add_transformers(
  qw(
    Data::Transform::PostProcess::UppercaseHashKeyIDSuffix
    Data::Transform::PostProcess::LowerCamelKeys
    )
);

my $h = {
  id      => 1,
  time    => '03:06',
  type_id => 6
};

is(
  $t1->transform($h), {
    id     => 1,
    time   => '03:06',
    typeId => 6,
  },
  'wrong-order registration'
);    # registration order matters!

my $t2 = Data::Transform->new();
$t2->add_transformers(
  qw(
    Data::Transform::PostProcess::LowerCamelKeys
    Data::Transform::PostProcess::UppercaseHashKeyIDSuffix
    )
);

is(
  $t2->transform($h), {
    id     => 1,
    time   => '03:06',
    typeID => 6,
  },
  'correct-order registration'
);

done_testing;
