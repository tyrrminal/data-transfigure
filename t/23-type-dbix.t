#!/usr/bin/perl
use v5.26;
use warnings;
use experimental qw(signatures);

use Test2::V0;

use Data::Transform::Type::DBIx;
use Data::Transform::Constants;

my $d = Data::Transform::Type::DBIx->new();

use FindBin qw($RealBin);
use lib "$RealBin/lib";
use MyApp::Schema;

my $schema = MyApp::Schema->connect('dbi:SQLite:dbname=:memory:','','');
my $author = $schema->resultset('Person')->new({firstname => 'Brandon', lastname => 'Sanderson' });
my $book = $schema->resultset('Book')->new({ title => 'The Final Empire', author => $author });

ok($d->applies_to(bless({}, 'MyClass'), '/'), $NO_MATCH, 'check dbix not applies_to (MyClass)');
ok($d->applies_to($book, '/'), $MATCH_INHERITED_TYPE, 'check dbix applies_to (book)');
ok($d->applies_to($author, '/'), $MATCH_INHERITED_TYPE, 'check dbix applies_to (person)');

ok($d->transform($book), { id => 1, title => 'The Final Empire', author_id => 1 }, 'non-recursive dbix transform (book)');
ok($d->transform($author), { id => 1, firstname => 'Brandon', lastname => 'Sanderson' }, 'non-recursive dbix transform (person)');

done_testing;
