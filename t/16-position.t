#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform::Position;
use Data::Transform::Constants;

my $book_1 = bless({id => 3, title => "War and Peace"},        'MyApp::Model::Result::Book');
my $book_2 = bless({id => 4, title => "A Tale of Two Cities"}, 'MyApp::Model::Result::Book');

my $d =Data::Transform::Position->new(
  position => '/shelf/book',
  handler => sub($entity) {
    return { title => $entity->{title} }
  }
);

my $o = {
  shelf => {
    book => $book_1
  },
  current => $book_2
};

is($d->applies_to($o, '/'),                            $NO_MATCH, 'check position applies_to (hash-outer)');
is($d->applies_to($o->{shelf}, '/shelf'),              $NO_MATCH, 'check position applies_to (hash-inner)');
is($d->applies_to($o->{shelf}->{book}, '/shelf/book'), $MATCH_EXACT_POSITION, 'check position applies_to (object)');
is($d->applies_to($o->{current}, '/current'),          $NO_MATCH, 'check position applies-to (wrong object)');

is($d->transform($o->{shelf}->{book}), { title => 'War and Peace'}, 'check transform at position');

done_testing;
