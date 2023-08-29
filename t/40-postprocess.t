#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;
use Test2::Tools::Mock qw(mock_obj);

use Data::Transform;
use Data::Transform::Type;
use Data::Transform::PostProcess;
use List::Util qw(sum);

my $count_values = Data::Transform::PostProcess->new(handler => sub($o) {
  if(ref($o) eq 'ARRAY') {
    return sum map { __SUB__->($_) } $o->@*
  } elsif(ref($o) eq 'HASH') {
    return sum map { __SUB__->($_) } values($o->%*)
  }
  return 1;
});

is($count_values->transform({a => 1, b => 2, c => { d => 4 }}), 3, 'count values recursive');

done_testing;
