#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform;

my $t = Data::Transform->new();
$t->register(qw(Data::Transform::PostProcess::LowerCamelKeys));

my $h = {id => 1};

is($t->transform($h), {id => 1}, 'id key');

$h = {ID => 1};

is($t->transform($h), {id => 1}, 'ID key');

$h = {book_id => 1};

is($t->transform($h), {bookId => 1}, '...Id key');

$h = [
  {id => {table_id => 3}},
  {
    list => [
      qw(
        book_id
        id
        table_id
        ID),
      {my_id => 3}
    ]
  }
];

is($t->transform($h), [{id => {tableId => 3}}, {list => ['book_id', 'id', 'table_id', 'ID', {myId => 3}]}], 'deep key rewrite');

done_testing;
