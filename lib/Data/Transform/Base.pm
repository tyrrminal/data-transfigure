package Data::Transform::Base;
use v5.26;
use warnings;

# ABSTRACT: the root role which all Data::Transform transformers must implement

=encoding UTF-8
 
=head1 NAME
 
Data::Transform::Base - the root role which all Data::Transform transformers 
must implement

=head1 DESCRIPTION

C<Data::Transform::Base> must be implemented by all transformers used by 
L<Data::Transform>

=cut

use Object::Pad;

role Data::Transform::Base {

=head1 FIELDS

=head2 handler (required param)

The handler param accepts a CODEREF/anonymous subroutine which itself receives 
a single parameter, the data element to transform, and is expected to return the
transformed value.

=cut

  field $handler : param;

=head1 METHODS

=head2 applies_to( %params )

C<applies_to> is required to be supplied by classes implementing this role.

This method recieves a param hash with keys C<value> and C<position> and returns
a constant from C<Data::Transform::_Internal::Constants> reflecting what degree
of match, if any, the transformer has to that node. Higher values are better 
matches.

=cut

  method applies_to;

=head2 transform( @args )

Executes the handler on the data element. Typically this shouldn't be called
manually or need to be overridden by subclasses.

=cut

  method transform (@args) {
    return $handler->(@args);
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
