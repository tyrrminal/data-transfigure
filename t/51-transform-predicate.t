#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform;
use Data::Transform::Predicate;
use Data::Transform::Type;

my $predicate_toggle = 0;

my $t = Data::Transform->new();
$t->add_transformers(
  Data::Transform::Type->new(
    type    => 'MyApp::Book',
    handler => sub ($entity) {
      +{map {$_ => $entity->{$_}} qw(id)};
    }
  ),
  Data::Transform::Predicate->new(
    predicate => sub ($value, $position) {
      $predicate_toggle;
    },
    transformer => Data::Transform::Type->new(
      type    => 'MyApp::Book',
      handler => sub ($entity) {
        +{map {$_ => $entity->{$_}} qw(id title)};
      }
    )
  )
);

my $book = bless({id => 2, title => 'War and Peace'}, 'MyApp::Book');
is($t->transform({book => $book}), {book => {id => 2}}, 'Predicate non-match test');
$predicate_toggle = 1;
is($t->transform({book => $book}), {book => {id => 2, title => 'War and Peace'}}, 'Predicate match test');

done_testing;
