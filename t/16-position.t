#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform qw(concat_position);
use Data::Transform::Position;
use Data::Transform::Default;
use Data::Transform::_Internal::Constants;

my $book_1 = bless({id => 3, title => "War and Peace"},        'MyApp::Model::Result::Book');
my $book_2 = bless({id => 4, title => "A Tale of Two Cities"}, 'MyApp::Model::Result::Book');

my $d = Data::Transform::Position->new(
  position    => '/shelf/book',
  transformer => Data::Transform::Default->new(
    handler => sub ($entity) {
      return {title => $entity->{title}};
    }
  )
);

my $o = {
  shelf => {
    book => $book_1
  },
  current => $book_2
};

my $base = concat_position(undef, undef);

is($d->applies_to(value => undef,          position => $base), $NO_MATCH, 'check position applies_to (hash-outer)');
is($d->applies_to(value => undef, position => concat_position($base, 'shelf')),
  $NO_MATCH, 'check position applies_to (hash-inner)');
is($d->applies_to(value => undef, position => concat_position(concat_position($base, 'shelf'), 'book')),
  $MATCH_EXACT_POSITION, 'check position applies_to (object)');
is($d->applies_to(value => undef, position => concat_position($base, 'current')),
  $NO_MATCH, 'check position applies-to (wrong object)');

is($d->transform($o->{shelf}->{book}), {title => 'War and Peace'}, 'check transform at position');

$d = Data::Transform::Position->new(
  position => ['/attachment','/elements/*/attachment', '/find/**/attachment'],
  transformer => Data::Transform::Default->new(
    handler => sub($entity) { undef }
  )
);

is($d->applies_to(value => undef, position => concat_position($base, 'current')), $NO_MATCH, 'check complex transform at position');

is($d->applies_to(value => undef, position => "/attachment"), $MATCH_EXACT_POSITION, "check attachment match");
is($d->applies_to(value => undef, position => "/my_attachment"), $NO_MATCH, "check attachment non-match");
is($d->applies_to(value => undef, position => "/elements/4/attachment"), $MATCH_WILDCARD_POSITION, "check inner attachment match");
is($d->applies_to(value => undef, position => "/find/this/anywhere/attachment"), $MATCH_WILDCARD_POSITION, "check double-wildcard attachment match");
is($d->applies_to(value => undef, position => "/not/this/anywhere/attachment"), $NO_MATCH, "check double-wildcard attachment no-match");

done_testing;
