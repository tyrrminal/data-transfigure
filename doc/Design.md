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
subclass.

Transformation works by iterating through all registered "general"
(meaning not the 3 cases listed above) transformers and determining their
`applies_to` value for a particular node/position in the data graph. `applies_to`
returns a constant from `Data::Transform::Constants`. Those that return
`$NO_MATCH` are ignored, and the remainder are sorted by match value
(higher being better) and then by order of being registered, so that later
additions can override previous ones. The best match is then selected, and used
to transform that node via the transformer's `transform` method.

# Implementation Details

`Data::Transform::Type::DBIx::Recursive` is a substantial improvment over the
plain `::DBIx` transformer, but still has a significant limitation in that it
can only traverse `to_one`-type data links. This is due to the fact that
`to_many` links are not distinguished between parent and child relationships, so
following them rapidly leads to infinite loops that would require substantially
more domain-specific coding, outside of the transformer itself, to handle.
