package Data::Transform::Tree::UppercaseHashKeyIDSuffix;
use v5.26;
use warnings;

# ABSTRACT: a post-process transformer that rewrites hash keys to replace /Id$/ with ID

=head1 NAME

Data::Transform::Tree::UppercaseHashKeyIDSuffix - a post-process 
transformer that rewrites hash keys to replace /Id$/ with ID

=head1 DESCRIPTION

C<Data::Transform::Tree::UppercaseHashKeyIDSuffix> addresses a side 
effect of camelCasing keys, which is that keys like C<user_id> are transformed
into C<userId> when you might prefer them to be C<userID>

=cut

use Object::Pad;

use Data::Transform::Tree;
class Data::Transform::Tree::UppercaseHashKeyIDSuffix : does(Data::Transform::Tree) {
  use Data::Transform qw(hk_rewrite_cb);

=head1 FIELDS

I<none>

=cut

  sub BUILDARGS ($class) {
    $class->SUPER::BUILDARGS(
      handler => sub ($entity) {
        return hk_rewrite_cb($entity, sub ($k) {$k =~ s/Id$/ID/r});
      }
    );
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