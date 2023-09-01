use v5.26;
use warnings;

# ABSTRACT: performs rule-based data transformations of arbitrary structures

=encoding UTF-8
 
=head1 NAME
 
Data::Transform - performs rule-based data transformations of arbitrary structures
 
=head1 SYNOPSIS

    use Data::Transform;

    my $d = Data::Transform->std();
    $d->add_transformers(qw(
      Data::Transform::Type::DateTime::Duration
      Data::Transform::PostProcess::LowerCamelKeys
    ), Data::Transform::Type->new(
      type    => 'Activity::Run'.
      handler => sub ($data) {
        {
          start    => $data->start_time, # DateTime
          time     => $data->time,       # DateTime::Duration
          distance => $data->distance,   # number
          pace     => $data->pace,       # DateTime::Duration
        }
      }
    ));

    my $list = [
      { user_id => 3, run  => Activity::Run->new(...) },
      { user_id => 4, ride => Activity::Ride->new(...) },
    ];

    $d->transform($list); # [
                          #   {
                          #     userID => 3
                          #     run    => {
                          #                 start    => "2023-05-15T074:11:14",
                          #                 time     => "PT30M5S",
                          #                 distance => "5",
                          #                 pace     => "PT9M30S",
                          #               }
                          #   },
                          #   {
                          #     userID => 4,
                          #     ride   => "Activity::Ride=HASH(0x2bbd7d16f640)",
                          #   },
                          # ]

=head1 DESCRIPTION

C<Data::Transform> allows you to write reusable rules ('transformers') to modify
parts (or all) of a data structure. There are many possible applications of this,
but it was primarily written to handle converting object graphs of ORM objects
into a structure that could be converted to JSON and delivered as an API endpoint
response. One of the challenges of such a system is being able to reuse code
because many different controllers could need to convert the an object type to
the same structure, but then other controllers might need to convert that same
type to a different structure.

A number of transformer roles and classes are included with this distribution:

=over

=item * L<Data::Transform::Base>
- the root role which all transformers must implement

=item * L<Data::Transform::Default>
- a low priority transformer that only applies when no other transformers do

=item * L<Data::Transform::Default::ToString>
- a transformer that stringifies any value that is not otherwise transformed

=item * L<Data::Transform::Type>
- a transformer that matches against one or more data types

=item * L<Data::Transform::Type::DateTime>
- transforms DateTime objects to L<ISO8601|https://en.wikipedia.org/wiki/ISO_8601> 
format. This is the same effect as stringification now, but is done explicitly 
e.g., in case DateTime ever changes how it stringifies.

=item * L<Data::Transform::Type::DateTime::Duration>
- transforms L<DateTime::Duration> objects to 
L<ISO8601|https://en.wikipedia.org/wiki/ISO_8601#Durations> (duration!) format

=item * L<Data::Transform::Type::DBIx>
- transforms L<DBIx::Class::Row> instances into hashrefs of colname->value 
pairs. Does not recurse across relationships

=item * L<Data::Transform::Type::DBIx::Recursive>
- transforms L<DBIx::Class::Row> instances into hashrefs of colname->value pairs,
recursing down to_one-type relationships

=item * L<Data::Transform::Value>
- a transformer that matches against data values (exactly, by regex, or by coderef 
callback)

=item * L<Data::Transform::Position>
- a compound transformer that specifies one or more locations within the data 
structure to apply to, in addition to whatever other criteria its transformer 
specifies

=item * L<Data::Transform::PostProcess>
- a transformer that is applied to the entire data structure after all 
non-postprocess transformations have been completed

=item * L<Data::Transform::PostProcess::LowerCamelKeys>
- a transformer that converts all hash keys in the data structure to 
lowerCamelCase

=item * L<Data::Transform::PostProcess::UppercaseHashKeyIDSuffix>
- a transformer that converts "Id" at the end of hash keys (as results from 
lowerCamelCase conversion) to "ID"

=back

=cut

use Object::Pad;

class Data::Transform 1.00 {
  use Exporter qw(import);

  use Data::Transform::Hash;
  use Data::Transform::Array;
  use Data::Transform::Default;
  use Data::Transform::Value;
  use Data::Transform::Position;

  use Data::Transform::_Internal::Constants;

  use List::Util   qw(max);
  use Module::Util qw(module_path);
  use Scalar::Util qw(blessed);
  use Readonly;

  field @transformers;

  our @EXPORT_OK = qw(hk_rewrite_cb concat_position);

  sub hk_rewrite_cb ($h, $cb) {
    if (ref($h) eq 'HASH') {
      foreach (keys($h->%*)) {
        hk_rewrite_cb($h->{$cb->($_)} = delete($h->{$_}), $cb);
      }
    } elsif (ref($h) eq 'ARRAY') {
      foreach my $o ($h->@*) {
        hk_rewrite_cb($o, $cb);
      }
    }
    return $h;
  }

  sub concat_position ($base, $add) {
    $base //= q{};
    $add  //= q{};
    $base =~ s|/+$||;
    $add  =~ s|^/+||;
    return join('/', ($base eq '/' ? '' : $base, $add));
  }

  my sub _transform ($data, $path, $transformers) {
    my @match;
    for (my $i = 0 ; $i < $transformers->@* ; $i++) {
      my $v = $transformers->[$i]->applies_to(value => $data, position => $path);
      push(@match, [$v, $i, $transformers->[$i]]) if ($v != $NO_MATCH);
    }
    return $data unless (@match);

    my $best_match = max(map {$_->[0]} @match);
    @match = sort {$b->[1] - $a->[1]} grep {$_->[0] == $best_match} @match;
    my $transformer = $match[0]->[2];
    my $nested      = $transformer->isa('Data::Transform::Array') || $transformer->isa('Data::Transform::Hash');

    my $d = $nested ? $transformer->transform($data, $path) : $transformer->transform($data);
    $d = __SUB__->($d, $path, $transformers) if (ref($d) && !$nested);

    return $d;
  }

=pod

=head1 CONSTRUCTORS

=head2 Data::Transform->new()

Constructs a new "bare-bones" instance that has no builtin data transformers, 
leaving it to the user to provide those.

=head2 Data::Transform->std()

Returns a standard instance that pre-adds L<Data::Transform::Default::ToString>
to stringify values that are not otherwise transformed by user-provided 
transformers. Preserves (does not transform to empty string) undefined values.

=cut

  sub std($class) {
    my $t = $class->new();
    $t->add_transformers(
      'Data::Transform::Default::ToString', 
      Data::Transform::Value->new(
        value => undef, 
        handler => sub ($data) { 
          return undef 
        }),
    );
    return $t;
  }

=pod

=head2 Data::Transform->dbix()

Builds off of the C<std()> instance, adding L<Data::Transform::DBIx::Recursive> 
to handle C<DBIx::Class> result rows

=cut

  sub dbix($class) {
    my $t = $class->std();
    $t->add_transformers(
      'Data::Transform::Type::DBIx::Recursive',
    );
    return $t;
  }

  ADJUST {
    $self->add_transformers(
      Data::Transform::Array->new(
        handler => sub ($data, $path) {
          my $i = 0;
          return [map {_transform($_, concat_position($path, $i++), [@transformers])} $data->@*];
        }
      )
    );

    $self->add_transformers(
      Data::Transform::Hash->new(
        handler => sub ($data, $path) {
          return {map {$_ => _transform($data->{$_}, concat_position($path, $_), [@transformers])} keys($data->%*)};
        }
      )
    );
  }

=pod

=head1 METHODS

=head2 add_transformers( @list )

Registers one or more data transformers with the C<Data::Transform> instance.

    $t->add_transformers(Data::Transform::Type->new(
      type    => 'DateTime',
      handler => sub ($data) {
        $data->strftime('%F')
      }
    ));

Each element of C<@list> must implement the L<Data::Transform::Base> role, though
these can either be strings containing class names or object instances.

C<Data::Transform> will automatically load class names passed in this list and 
construct an object instance from that class. This will fail if the class's C<new>
constructor does not exist or has required parameters.

    $t->add_transformers(qw(Data::Transform::Type::DateTime Data::Transform::Type::DBIx));

ArrayRefs passed in this list will be expanded and their contents will be treated
the same as any item passed directly to this method.

    my $default = Data::Transform::Type::Default->new(
      handler => sub ($data) {
        "[$data]"
      }
    );
    my $bundle = [q(Data::Transform::Type::DateTime), $default];
    $t->add_transformers($bundle);

When transforming data, only one transformer will be applied to each data element,
prioritizing the most-specific types of matches. Among transformers that have 
equal match types, those added later have priority over those added earlier.

=cut

  method add_transformers(@args) {
    foreach my $t (map {ref($_) eq 'ARRAY' ? $_->@* : $_} @args) {
      if(!defined($t)) {
        die("Cannot register undef");
      } elsif(ref($t)) {
        die("Cannot register non-Data::Transform::Base implementers ($t)") unless ($t->DOES('Data::Transform::Base'));
      } elsif($t eq 'Data::Transform::Base') {
        die('Cannot register Role');
      } else {
        require(module_path($t));
        die("Cannot register non-Data::Transform::Base implementers ($t)") unless ($t->DOES('Data::Transform::Base'));
        $t = $t->new()                                                     unless (ref($t));
      }
      push(@transformers, $t);
    }
    return wantarray ? @transformers : scalar @transformers;
  }

=pod

=head2 add_transformer_at( $position => $transformer )

C<add_transformer_at> is a convenience method for creating and adding a 
positional transformer (one that applies to a specific data-path within the given
structure) in a single step.

See L<Data::Transform::Position> for more on positional transformers.

=cut

  method add_transformer_at($position, $transformer) {
    push(@transformers, Data::Transform::Position->new(
      position    => $position,
      transformer => $transformer
    ));
  }

=pod

=head2 transform( $data )

Transforms the data according to the transformers added to the instance and 
returns it. The data structure passed to the method is unmodified.

=cut

  method transform($data) {
    my $d = _transform($data, '/', [grep {!$_->isa('Data::Transform::PostProcess')} @transformers]);
    foreach (grep {$_->isa('Data::Transform::PostProcess')} @transformers) {
      $d = $_->transform($d);
    }
    return $d;
  }

}

=pod

=head1 AUTHOR

Mark Tyrrell C<< <mtyrrell@cpan.org> >>

=head1 LICENSE

Copyright (c) 2023 Mark Tyrrell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut

1;

__END__
