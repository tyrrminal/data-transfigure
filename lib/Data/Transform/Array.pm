use v5.26;
use warnings;

# ABSTRACT: a transformer for iterating an arrayref

=encoding UTF-8

=head1 NAME

Data::Transform::Array - a transformer for iterating an arrayref

=head1 DESCRIPTION

C<Data::Transform::Array> is used internally by L<Data::Transform> for arrayref
iteration. Do not subclass or instantiate it unless you know what you are doing
or it is likely to result in unbounded recursion.

=cut

use Object::Pad;

class Data::Transform::Array : does(Data::Transform::Base) : strict(params) {
  use Data::Transform::_Internal::Constants;

=head1 METHODS

=head2 applies_to( %params )

Returns highest-possible match type C<$MATCH_EXACT> if C<$params{value}> is an
arrayref; lowst-possible match type C<$NO_MATCH> otherwise.

=cut

  method applies_to(%params) {
    die('value is a required parameter for Data::Transform::Array->applies_to') unless (exists($params{value}));
    my $node = $params{value};

    return $MATCH_EXACT if (ref($node) eq 'ARRAY');
    return $NO_MATCH;
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
