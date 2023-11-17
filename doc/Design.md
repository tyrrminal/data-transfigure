# Overview

Data::Transform is a perl module for applying simple, reusable, context-aware
transformations to arbitrarily complex data structures.

# Context

This module is designed to be as general as possible to facilitate any sort of 
data transformation context. While users are free to enhance its abilities by
providing their own transformers, it does bundle a small number of them to 
address specific scenarios as an example/convenience.

# Goals

To accept a data structure (which could be as simple as a single element), 
process it, and return a new data structure in a desired format.

Also, to permit the use of modules ("transformers") to perform specific 
transformation tasks in a way that is compartmentalized, reusable, and largely
declarative.

Further, to allow transformers to override previously-defined and less-specific
transformers so as to facilitate greater code reuse, e.g., by having a standard
set of transformers "app-wide" and then overriding one or more specific 
transformers when needed.

And finally, to facilitate extension of transformers through standard OOP
principles to customize and modify behaviors in a code-minimal manner.

# Non-Goals

There is no goal to have comprehensive or all-encompassing coverage of even
simple transformer types bundled into this module.

# Implementation

Object::Pad was selected as the OOP paradigm for this module for its similarity
with perlclass, but at this time being more featureful in ways that were needed
to implement necessary inheritence/composition (namely that perlclass does not
(yet?) expose the functionality for a subclass to satisfy parameter requirements 
of its parent.)

Data::Transform is the main module of this package, providing the functionality
for registering transformers and transforming data structures.

Data::Transform::Node provides a role which must be composed by any transformer
in order to be registerable with Data::Transform.

Likewise, Data::Transform::Tree provides a role to be composed by transformers
used for postprocessing. These are applied after all node transformations, and 
they receive the entire data structure rather than just a single node at a time.

The other classes included with this package compose Data::Transform::Node or 
Data::Transform::Tree to provide convenient bases to instantiate and/or 
subclass, though two of them have specialized heuristics:

* Data::Transform::Array and Data::Transform::Hash are used internally by 
Data::Transform to iterate complex data structures. They can be overridden by 
registering new transformers of these types, but this is not presently a
supported operation and will likely cause problems.

Otherwise, transformation works by iterating through all registered "general" 
(meaning not the 3 cases listed above) transformers and determining their 
`applies_to` value for a particular node/position in the data graph. `applies_to`
returns a constant from `Data::Transform::Constants`. Those that
return `$NO_MATCH` are ignored, and the remainder are sorted by match value 
(higher being better) and then by order of being registered, so that later
additions can override previous ones. The best match is then selected, and used
to transform that node via the transformer's `transform` method.

# Implementation Details

Most of the heavy lifting is done by `Data::Transform::_transform()` and not the 
public `transform()` method, since the former needs to recursively call itself
as it iterates through nodes, and the latter needs to handle postprocessing when
the former completes.

This recursion works by taking the output from a transformer and immediately
-- if it is a reference -- calling `_transform()` on it. Because the default 
Hash and Array transformers return new hashrefs and arrayrefs, these are 
excempted from this recursive processing because it would cause unbounded 
recursion - instead, the array and hash handlers need to call `_transform()` on 
each of their node's values.

`Data::Transform::Type::DBIx::Recursive` is a substantial improvment over the 
plain `::DBIx` transformer, but still has a significant limitation in that it
can only traverse `to_one`-type data links. This is due to the fact that 
`to_many` links are not distinguished between parent and child relationships, so
following them rapidly leads to infinite loops that would require substantially
more domain-specific coding, outside of the transformer itself, to handle.

# Open Questions

* A consequence of the previous paragraph is that transformers must be careful
not to return anything that they might themselves match as this could also lead
to unbounded recursion. Is it good-enough to merely document this or is this a 
case that users' will run into often enough that a fix should be established?

* `applies_to()` is designed to return one of a limited set of constants, but
implmentors could override it to return anything. This could make it possible,
for example, to create a custom transformer that matches better than the builtin
array or hash transformers, overriding them, and causing chaos and destruction.
If implementors behave, this isn't a problem, but maybe we should be doing more
to value-check this result?
