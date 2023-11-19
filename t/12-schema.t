#!/usr/bin/perl
use v5.26;
use warnings;

use Test2::V0;
use Test2::Tools::Compare qw(check_isa);

use Data::Transform;
use Data::Transform::Schema;
use Data::Transform::Constants;
use JSON::Validator::Joi 'joi';

use experimental qw(signatures);

my $jv = JSON::Validator->new;
my $schema = $jv->schema(
  joi->object->props(
    age   => joi->integer->min(0)->max(200),
    email => joi->string->regex(".@.")->required,
    name  => joi->string->min(1),
  )->compile
);

my $d = Data::Transform::Schema->new(
  schema => $schema,
  handler => sub ($entity) {
    bless($entity, 'MyPersonClass')
  }
);
my $o = {age => 17, email => 'me@myself.com', name => 'John Smith'};

is($d->applies_to(value => {}), $NO_MATCH, 'Schema no match');
is($d->applies_to(value => $o), $MATCH_EXACT_VALUE, 'Schema match'); 

my $t = Data::Transform->bare();
$t->add_transformers($d);
my $c = $t->transform($o);

is($c, check_isa('MyPersonClass'), 'Schema class transform');

done_testing;
