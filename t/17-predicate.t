#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;

use Data::Transform::Predicate;
use Data::Transform::Type;
use Data::Transform::Constants;

use experimental qw(signatures);

my $book = bless({id => 1, title => 'War and Peace'}, 'MyApp::Model::Result::Book');

my $toggle = 0;

my $type = Data::Transform::Type->new(
  type => 'MyApp::Model::Result::Book',
  handler => sub ($entity) {
    return {id => $entity->title}
  }
);

my $predicate = Data::Transform::Predicate->new(
  predicate => sub ($value, $position) {
    return $toggle
  },
  transformer => Data::Transform::Type->new(
    type => 'MyApp::Model::Result::Book',
    handler => sub ($entity) {
      +{ 
        map { $_ => $entity->$_ } qw(id title)
      }
    }
  )
);

is($type->applies_to(value => $book, position => '/'), $MATCH_EXACT_TYPE, 'basic type match');
is($predicate->applies_to(value => $book, position => '/'), $NO_MATCH, 'check predicate non-match');

$toggle = 1;

is($type->applies_to(value => $book, position => '/'), $MATCH_EXACT_TYPE, 'basic type match (2)');
is($predicate->applies_to(value => $book, position => '/'), $MATCH_EXACT_TYPE, 'check predicate match');

done_testing;
