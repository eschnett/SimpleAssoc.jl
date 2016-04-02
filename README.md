# SimpleAssoc

[![Build Status](https://travis-ci.org/eschnett/SimpleAssoc.jl.svg?branch=master)](https://travis-ci.org/eschnett/SimpleAssoc.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/aqed7gm0okmutgit/branch/master?svg=true)](https://ci.appveyor.com/project/eschnett/simpleassoc-jl/branch/master)
[![codecov.io](https://codecov.io/github/eschnett/SimpleAssoc.jl/coverage.svg?branch=master)](https://codecov.io/github/eschnett/SimpleAssoc.jl?branch=master)

Simple associative collections based on (unsorted) arrays

## Overview

This package provides two types `AssocArray` and `AssocTuple`. Both
types are simple associative collections that behave like `Dict` (or
an immutable version of `Dict`). The major difference is that they use
a simpler internal representation, based on unsorted arrays (or
unsorted tuples). This can be faster than a `Dict` if the collection
is small, or if the collection is searched only infrequently.

The `runtest.jl` file contains extensive test cases that also
demonstrate the syntax. There are really no surprises:

```Julia
using SimpleAssoc

a0 = AssocArray()
a1 = AssocArray('a'=>1)
a2 = AssocArray('a'=>1, 'b'=>2)
a3 = AssocArray([('a',1), ('b',2)])

a0 = AssocArray{Char,Int}()
a1 = AssocArray{Char,Int}('a'=>1)
a2 = AssocArray{Char,Int}('a'=>1, 'b'=>2)
a3 = AssocArray{Char,Int}([('a',1), ('b',2)])

t0 = AssocTuple()
t1 = AssocTuple('a'=>1)
t2 = AssocTuple('a'=>1, 'b'=>2)
t3 = AssocTuple([('a',1), ('b',2)])

t0 = AssocTuple{Char,Int}()
t1 = AssocTuple{Char,Int}('a'=>1)
t2 = AssocTuple{Char,Int}('a'=>1, 'b'=>2)
t3 = AssocTuple{Char,Int}([('a',1), ('b',2)])
```

These collections can be accessed and modified in the usual way
(`get`, `getindex`, `setindex!`, via iterators, etc.); the full range
of functions for associative collections should be available. The only
notable property is that `AssocTuple` is (by construction) an
immutable type, and hence `setindex!` etc. are not defined.
