#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;
use Test2::Tools::Warnings  qw(warns);
use Test2::Tools::Exception qw(dies lives);
use Test2::Tools::Compare   qw(check_isa);

use Data::Transform;

use experimental qw(signatures);

# Transformer registration tests
like(dies {Data::Transform->bare->add_transformers(undef)}, qr/^Cannot register undef/, 'attempt to register undef');

my $msg = q{Can't locate NonexistentClass.pm in @INC};
like(dies {Data::Transform->bare->add_transformers('NonexistentClass')}, qr/^\Q$msg/, 'attempt to register non-existent class');

like(
  dies {Data::Transform->bare->add_transformers('File::Spec')},
  qr|^Cannot register non-Data::Transform::Node/Tree implementers|,
  'attempt to register class not implementing Data::Transform::Node'
);

ok(lives {Data::Transform->bare->add_transformers('Data::Transform::Type::DateTime')},
  'register class that has no required parameters');

like(
  dies {Data::Transform->bare->add_transformers('Data::Transform::Node')},
  qr/^Cannot register Role/,
  'attempt to register class that has required parameters'
);

# Transformation tests
## no default handler
my $t = Data::Transform->bare();
isa_ok($t->transform(bless({day => 3, month => 4, year => 2005}, 'MyDateTime')), ['MyDateTime'], 'no default handler');
is($t->transform(undef), undef, 'no default handler - undef');

$t = Data::Transform->bare();
$t->add_transformers(qw(Data::Transform::Default::ToString));
like(bless({day => 3, month => 4, year => 2005}, 'MyDateTime'), qr/MyDateTime=HASH\(0x[0-9a-f]+\)/, 'default to-string handler');
is(warns {$t->transform(undef)}, 1, 'warning for uninitialized stringification');
{
  local $SIG{__WARN__} = sub { };    # kill the warning we just verified and check the actual value
  is($t->transform(undef), '', 'default stringification of undef to empty string');
}

$t = Data::Transform->new();
like(bless({day => 3, month => 4, year => 2005}, 'MyDateTime'), qr/MyDateTime=HASH\(0x[0-9a-f]+\)/,
  'std default to-string handler');
is($t->transform(undef), undef, 'std handler maintains undef in spite of default stringification');

use Data::Transform::Type;

my $date = Data::Transform::Type->new(
  type    => 'DateTime',
  handler => sub ($node) {
    return $node->strftime("%F");
  }
);

$t = Data::Transform->bare();

ok($t->add_transformers($date), 'register custom type transformer');

use DateTime;

my $dt = DateTime->new(year => 2015, month => 8, day => 27, hour => 12, minute => 0, second => 8);

is($t->transform($dt), "2015-08-27", 'apply custom date transformer');

is(
  $t->transform([[[{title => 'War and Peace'}, {date => $dt}]]]),
  [[[{title => 'War and Peace'}, {date => "2015-08-27"}]]],
  'apply custom date transformer (nested)'
);

use Data::Transform::Default;

ok($t->add_transformers(Data::Transform::Default->new(handler => sub ($value) {"//$value//"})),
  'register default transformer (override)');

is(
  $t->transform({title => 'War and Peace', pages => 1200}),
  {title => '//War and Peace//', pages => '//1200//'},
  'apply overridden default transformer'
);

$t = Data::Transform->bare();
$t->add_transformer_at(
  "/book/author" => Data::Transform::Type->new(
    type    => 'MyApp::Person',
    handler => sub ($data) {
      return $data->{firstname};
    }
  )
);

is(
  $t->transform(
    {
      book     => {author => bless({firstname => 'John'}, 'MyApp::Person')},
      some_guy => bless({firstname => 'Bob'}, 'MyApp::Person')
    }
  ),
  {book => {author => 'John'}, some_guy => check_isa('HASH')},
  'check that positional transformer applies to book>author but not some_guy'
);

done_testing;
