package Data::Transform::PostProcess;
use v5.26;
use warnings;

# ABSTRACT: a transformer that is applied to the entire data structure

=head1 NAME

Data::Transform::PostProcess - a transformer that is applied to the entire data 
structure, after all non-postprocess transformations have been completed

=head1 DESCRIPTION

C<Data::Transform::PostProcess> transformers are used to "clean-up" the data
structure after all other transformations have been applied. 

=cut

use Object::Pad;

class Data::Transform::PostProcess : does(Data::Transform::Base) {
  use Data::Transform::_Internal::Constants;

=head1 METHODS

=head2 applies_to( %params )

In the current implementation, the result of C<Data::Transform::PostProcess> and
subclasses' C<applies_to> is not checked, but the method must be implemented to
satisfy the base role, so it simply returns undef.

=cut

  method applies_to (%params) {
    return undef;
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
