#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform;

my $t = Data::Transform->bare();
$t->add_transformers(qw(Data::Transform::Tree::UppercaseHashKeyIDSuffix));

my $h = {id => 1};

is($t->transform($h), {id => 1}, 'id key');

$h = {ID => 1};

is($t->transform($h), {ID => 1}, 'ID key');

$h = {bookId => 1};

is($t->transform($h), {bookID => 1}, '...Id key');

$h = [
  {id => {tableId => 3}},
  {
    list => [
      qw(
        bookId
        id
        tableId
        ID),
      {myId => 3}
    ]
  }
];

is($t->transform($h), [{id => {tableID => 3}}, {list => ['bookId', 'id', 'tableId', 'ID', {myID => 3}]}], 'deep key rewrite');

done_testing;
