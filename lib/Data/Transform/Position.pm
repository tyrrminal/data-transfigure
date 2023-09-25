package Data::Transform::Position;
use v5.26;
use warnings;

# ABSTRACT: a compound transformer that specifies one or more locations within the data structure to apply to

=head1 NAME

Data::Transform::Position - a compound transformer that specifies one or more 
locations within the data structure to apply to

=head1 SYNOPSIS

    Data::Transform::Position->new(
      position => '/*/author',
      transformer => Data::Transform::Type->new(
        type => 'Result::Person',
        handler => sub ($data) {
          sprintf("%s, %s", $data->lastname, $data->firstname)
        }
      )
    ); # applies to any 2nd-level hash key "author", but only if that value's
       # type is 'Result::Person', and then performs a custom stringification

    Data::Transform::Position->new(
      position => '/book/author',
      transformer => Data::Transform::Default->new(
        handler => sub ($data ) {
          {
            firstname => $data->names->{first} // '',
            lastname  => $data->names->{last} // '',
          }
        }
      )
    ); # applies only to the node at $data->{book}->{author}, and tries to 
       # hash-ify the value there, regardless of its type.

=head1 DESCRIPTION

C<Data::Transform::Position> is a compound transformer, meaning that it both is,
and has, a transformer. The transformer you give it at construction can be of 
any type, with its own handler and match criteria. The 
C<Data::Transform::Position>'s handler will become the one from the supplied
transformer, so C<handler> should not be specified when creating this 
transformer.

This construction is used so that transformers can be treated like building
blocks and in some cases inserted to apply to the entire tree, but in other
scenarios, used much more specifically.

=cut

use Object::Pad;

class Data::Transform::Position : does(Data::Transform::Node) {
  use Data::Transform::_Internal::Constants;

=head1 FIELDS

=head2 position (required parameter)

Ex. C<"/book/author">, C<"/*/*/title">, C<"/values/0/id">

A position specifier for a location in the data structure. The forward slash
character is used to delineate levels, which are hashes or arrays. The asterisk
character can be used to represent "anything" at that level, whether hash key
or array index.

Cam be an arrayref of position specifiers to match any of them.

=head2 transformer (required parameter)

A C<Data::Transform> transformer conforming to the C<Data::Transform::Node> 
role. Weird things will happen if you provide a 
C<Data::Transform::Tree> -type transformer, so you probably shouldn't do
that.

=cut

  field $position : param;
  field $transformer : param;

  my sub wildcard_to_regex ($str) {
    $str =~ s|[.]|\\.|g;
    $str =~ s|[*]|.*|g;
    return map {qr/^$_$/} split(q{/}, $str);
  }

  sub BUILDARGS ($class, %params) {
    $class->SUPER::BUILDARGS(
      position    => $params{position},
      transformer => $params{transformer},
      handler     => sub (@args) {
        $params{transformer}->transform(@args);
      }
    );
  }

=head1 applies_to( %params )

C<$params{position}> must exist, as well as any params required by the supplied
transformer.

Passes C<%params> to the instance's transformer's C<applies_to> method - if that
results in C<$NO_MATCH>, then that value is returned by this method.

Then, the C<position(s)> is/are checked against C<$params{position}>. If 
any matches exactly, returns C<$MATCH_EXACT_POSITION>. Otherwise, if any matches
with wildcard evaluation, returns C<$MATCH_WILDCARD_POSITION>.

If no positions match, returns C<$NO_MATCH>

=cut

  method applies_to (%params) {
    die('position is a required parameter for Data::Transform::Position->applies_to') unless (exists($params{position}));
    my $loc = $params{position};

    my $rv = $NO_MATCH;
    return $rv if ($transformer->applies_to(%params) == $NO_MATCH);
    my @paths = ref($position) eq 'ARRAY' ? $position->@* : ($position);

    PATH: foreach (@paths) {
      return $MATCH_EXACT_POSITION if ($loc eq $_);
      my @re = wildcard_to_regex($_);
      my @parts = split(q{/}, $loc);
      next if(@parts != @re);
      for (my $i=0; $i<$#re+1; $i++) {
        next PATH unless($parts[$i] =~ $re[$i]);
      }
      $rv = $MATCH_WILDCARD_POSITION;
    }
    return $rv;
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
