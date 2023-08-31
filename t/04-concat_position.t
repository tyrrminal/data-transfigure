#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;
use Test2::Tools::Exception qw(dies);

use Data::Transform qw(concat_position);
my $ps = $Data::Transform::POSITION_SEP;

like(
  dies {concat_position()},
  qr/Too few arguments for subroutine 'Data::Transform::concat_position' \(got 0; expected 2\)/,
  'no arguments to concat_position'
);

is(concat_position(undef, undef), $ps, 'concat undef with undef');
is(concat_position('',    undef), $ps, 'concat empty with undef');
is(concat_position(undef, ''),    $ps, 'concat undef with empty');

my $base;

is(concat_position($base, 'a'), "${ps}a", 'concat undef with a');

$base = '';

is(concat_position($base, 'a'), "${ps}a", 'concat empty with a');

$base = $ps;

is(concat_position($base, 'a'), "${ps}a", 'concat / with a');

$base = concat_position($base, 'a');

is(concat_position($base, 'b'), "${ps}a${ps}b", 'concat /a with b');

is(concat_position($base, "${ps}b"), "${ps}a${ps}b", 'concat /a with /b');

is(concat_position("$base$ps", "b"), "${ps}a${ps}b", 'concat /a/ with b');

done_testing;
