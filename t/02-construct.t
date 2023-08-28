#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform;

my $t = Data::Transform->new();

is(ref($t), 'Data::Transform', 'constructor');

done_testing;
