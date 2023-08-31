#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform::Type::DBIx::Recursive;
use Data::Transform::Constants;

my $d = Data::Transform::Type::DBIx::Recursive->new();

use FindBin qw($RealBin);
use lib "$RealBin/lib";
use MyApp::Schema;

my $schema = MyApp::Schema->connect('dbi:SQLite:dbname=:memory:','','');
my $author = $schema->resultset('Person')->new({firstname => 'Brandon', lastname => 'Sanderson' });
my $book = $schema->resultset('Book')->new({ title => 'The Final Empire', author => $author });

ok($d->applies_to($author, '/'), $MATCH_INHERITED_TYPE, 'check dbix-recursive applies_to (person)');
ok($d->applies_to($book, '/'), $MATCH_INHERITED_TYPE, 'check dbix-recursive applies_to (book)');

ok($d->transform($author), { id => 1, firstname => 'Brandon', lastname => 'Sanderson' }, 'dbix-recursive transform (person)');
ok($d->transform($book), { id => 1, title => 'The Final Empire', author => { id => 1, firstname => 'Brandon' } }, 'dbix-recursive transform (book)');

done_testing;
