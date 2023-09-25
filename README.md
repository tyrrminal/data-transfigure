# NAME

Data::Transform - performs rule-based data transformations of arbitrary structures

# SYNOPSIS

    use Data::Transform;

    my $d = Data::Transform->std();
    $d->add_transformers(qw(
      Data::Transform::Type::DateTime::Duration
      Data::Transform::Tree::LowerCamelKeys
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

# DESCRIPTION

`Data::Transform` allows you to write reusable rules ('transformers') to modify
parts (or all) of a data structure. There are many possible applications of this,
but it was primarily written to handle converting object graphs of ORM objects
into a structure that could be converted to JSON and delivered as an API endpoint
response. One of the challenges of such a system is being able to reuse code
because many different controllers could need to convert the an object type to
the same structure, but then other controllers might need to convert that same
type to a different structure.

A number of transformer roles and classes are included with this distribution:

- [Data::Transform::Node](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ABase)
- the root role which all transformers must implement
- [Data::Transform::Default](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ADefault)
- a low priority transformer that only applies when no other transformers do
- [Data::Transform::Default::ToString](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ADefault%3A%3AToString)
- a transformer that stringifies any value that is not otherwise transformed
- [Data::Transform::Type](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AType)
- a transformer that matches against one or more data types
- [Data::Transform::Type::DateTime](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AType%3A%3ADateTime)
- transforms DateTime objects to [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) 
format.
- [Data::Transform::Type::DateTime::Duration](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AType%3A%3ADateTime%3A%3ADuration)
- transforms [DateTime::Duration](https://metacpan.org/pod/DateTime%3A%3ADuration) objects to 
[ISO8601](https://en.wikipedia.org/wiki/ISO_8601#Durations) (duration!) format
- [Data::Transform::Type::DBIx](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AType%3A%3ADBIx)
- transforms [DBIx::Class::Row](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3ARow) instances into hashrefs of colname->value 
pairs. Does not recurse across relationships
- [Data::Transform::Type::DBIx::Recursive](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AType%3A%3ADBIx%3A%3ARecursive)
- transforms [DBIx::Class::Row](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3ARow) instances into hashrefs of colname->value pairs,
recursing down to\_one-type relationships
- [Data::Transform::Value](https://metacpan.org/pod/Data%3A%3ATransform%3A%3AValue)
- a transformer that matches against data values (exactly, by regex, or by coderef 
callback)
- [Data::Transform::Position](https://metacpan.org/pod/Data%3A%3ATransform%3A%3APosition)
- a compound transformer that specifies one or more locations within the data 
structure to apply to, in addition to whatever other criteria its transformer 
specifies
- [Data::Transform::Tree](https://metacpan.org/pod/Data%3A%3ATransform%3A%3APostProcess)
- a transformer that is applied to the entire data structure after all 
node transformations have been completed
- [Data::Transform::Tree::LowerCamelKeys](https://metacpan.org/pod/Data%3A%3ATransform%3A%3APostProcess%3A%3ALowerCamelKeys)
- a transformer that converts all hash keys in the data structure to 
lowerCamelCase
- [Data::Transform::Tree::UppercaseHashKeyIDSuffix](https://metacpan.org/pod/Data%3A%3ATransform%3A%3APostProcess%3A%3AUppercaseHashKeyIDSuffix)
- a transformer that converts "Id" at the end of hash keys (as results from 
lowerCamelCase conversion) to "ID"

# CONSTRUCTORS

## Data::Transform->new()

Constructs a new "bare-bones" instance that has no builtin data transformers, 
leaving it to the user to provide those.

## Data::Transform->std()

Returns a standard instance that pre-adds [Data::Transform::Default::ToString](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ADefault%3A%3AToString)
to stringify values that are not otherwise transformed by user-provided 
transformers. Preserves (does not transform to empty string) undefined values.

## Data::Transform->dbix()

Builds off of the `std()` instance, adding [Data::Transform::DBIx::Recursive](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ADBIx%3A%3ARecursive) 
to handle `DBIx::Class` result rows

# METHODS

## add\_transformers( @list )

Registers one or more data transformers with the `Data::Transform` instance.

    $t->add_transformers(Data::Transform::Type->new(
      type    => 'DateTime',
      handler => sub ($data) {
        $data->strftime('%F')
      }
    ));

Each element of `@list` must implement the [Data::Transform::Node](https://metacpan.org/pod/Data%3A%3ATransform%3A%3ABase) role, though
these can either be strings containing class names or object instances.

`Data::Transform` will automatically load class names passed in this list and 
construct an object instance from that class. This will fail if the class's `new`
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

## add\_transformer\_at( $position => $transformer )

`add_transformer_at` is a convenience method for creating and adding a 
positional transformer (one that applies to a specific data-path within the given
structure) in a single step.

See [Data::Transform::Position](https://metacpan.org/pod/Data%3A%3ATransform%3A%3APosition) for more on positional transformers.

## transform( $data )

Transforms the data according to the transformers added to the instance and 
returns it. The data structure passed to the method is unmodified.

# AUTHOR

Mark Tyrrell `<mtyrrell@cpan.org>`

# LICENSE

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
