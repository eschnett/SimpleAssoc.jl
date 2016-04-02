using SimpleAssoc
using Base.Test

"Compare two iterables without regard to order"
itercmp(i1, i2) = isequal(sort(collect(i1)), sort(collect(i2)))

################################################################################

# Constructors
a0 = AssocArray{Char,Int}()
a1 = AssocArray{Char,Int}('a'=>1)
a1f = AssocArray{Char,Int}('a'=>1.0)
a2 = AssocArray{Char,Int}('a'=>1, 'b'=>2)

# Deducing the element type
a0 = AssocArray()
@test isa(a0, AssocArray{Any,Any})
a1 = AssocArray('a'=>1)
@test isa(a1, AssocArray{Char,Int})
a2 = AssocArray('a'=>1, 'b'=>2)
@test isa(a2, AssocArray{Char,Int})

# Constructing from a Pair vs. constructing from an iterator
a1 = AssocArray(('a'=>1) => ('b'=>2))
@test isa(a1, AssocArray{Pair{Char,Int}, Pair{Char,Int}})
a2 = AssocArray(('a'=>1), ('b'=>2))
@test isa(a2, AssocArray{Char,Int})
a3 = AssocArray((('a'=>1), ('b'=>2)))
@test isa(a3, AssocArray{Char,Int})
a4 = AssocArray(Pair{Char,Int}[('a'=>1), ('b'=>2)])
@test isa(a4, AssocArray{Char,Int})
a5 = AssocArray((('a',1), ('b',2)))
@test isa(a5, AssocArray{Char,Int})
a6 = AssocArray([('a',1), ('b',2)])
@test isa(a6, AssocArray{Char,Int})

# Type properties
a0 = AssocArray{Char,Int}()
@test eltype(a0) === Pair{Char,Int}
a0 = AssocArray()
@test eltype(a0) === Pair{Any,Any}
@test eltype(a1) === Pair{Pair{Char,Int}, Pair{Char,Int}}
@test eltype(a2) === Pair{Char,Int}

# Object properties
@test isempty(a0)
@test !isempty(a1)
@test !isempty(a2)
@test length(a0) == 0
@test length(a1) == 1
@test length(a2) == 2

# Iterators

@test itercmp(a0, Pair{Char,Int}[])
@test itercmp(a1, Pair{Pair{Char,Int}, Pair{Char,Int}}[('a'=>1) => ('b'=>2)])
@test itercmp(a2, Pair{Char,Int}[('a'=>1), ('b'=>2)])

@test itercmp(keys(a0), Char[])
@test itercmp(keys(a1), Pair{Char,Int}['a'=>1])
@test itercmp(keys(a2), Char['a', 'b'])

@test itercmp(values(a0), Int[])
@test itercmp(values(a1), Pair{Char,Int}['b'=>2])
@test itercmp(values(a2), Int[1, 2])

@test itercmp(eachindex(a0), keys(a0))
@test itercmp(eachindex(a1), keys(a1))
@test itercmp(eachindex(a2), keys(a2))

# Duplicate keys
b1 = AssocArray{Char,Int}([('a',1), ('a',2), ('b',2), ('a',1)])
@test itercmp(b1, a2)
b2 = AssocArray{Char,Int}('a'=>1, 'a'=>2, 'b'=>2, 'a'=>1)
@test itercmp(b2, a2)
b3 = AssocArray([('a',1), ('a',2), ('b',2), ('a',1)])
@test itercmp(b3, a2)
b4 = AssocArray('a'=>1, 'a'=>2, 'b'=>2, 'a'=>1)
@test itercmp(b4, a2)

# Mutating operations
empty!(a0)
@test isempty(a0)
empty!(a1)
@test isempty(a1)
empty!(a2)
@test isempty(a2)

# Element-wise access

a0['a'] = 1
@test a0['a'] == 1
@test length(a0) == 1
a0['b'] = -1
@test a0['b'] == -1
@test length(a0) == 2
a0['b'] = 2
@test a0['b'] == 2
@test length(a0) == 2
get!(a0, 'b', 3)
@test a0['b'] == 2
@test length(a0) == 2
get!(a0, 'c', 3)
@test a0['c'] == 3
@test length(a0) == 3
@test get(a0, 'c', 4) == 3
@test get(a0, 'd', 4) == 4
@test haskey(a0, 'c')
@test getkey(a0, 'c', 4) == 'c'
@test !haskey(a0, 'd')
@test getkey(a0, 'd', 4) == 4
@test itercmp(a0, ('a'=>1, 'b'=>2, 'c'=>3))

@test_throws KeyError a0['A']

# Delete elements

delete!(a0, 'b')
@test length(a0) == 2
@test_throws KeyError a0['b']
delete!(a0, 'c')
@test length(a0) == 1
@test_throws KeyError a0['c']
delete!(a0, 'a')
@test length(a0) == 0
@test_throws KeyError a0['a']
delete!(a0, 'a')
@test length(a0) == 0

# Copy collection

a4c = copy(a4)
@test isequal(a4c, a4)
@test a4c !== a4

# push and pop

x = pop!(a4)
@test length(a4) == 1
y = pop!(a4)
@test length(a4) == 0
@test x != y

push!(a4, x)
@test length(a4) == 1
push!(a4, y)
@test length(a4) == 2

@test isequal(a4, a4c)

################################################################################

# Constructors

t0 = AssocTuple{Char,Int,0}()
t1 = AssocTuple{Char,Int,1}('a'=>1)
t2 = AssocTuple{Char,Int,1}('a'=>1.0)

t0 = AssocTuple{Char,Int}()
t1 = AssocTuple{Char,Int}('a'=>1)
t2 = AssocTuple{Char,Int}('a'=>1.0)

t0 = AssocTuple()
t1 = AssocTuple('a'=>1)
t2 = AssocTuple('a'=>1.0)

# Deducing the element type
t1 = AssocTuple('a'=>1)
@test isa(t1, AssocTuple{Char,Int})
t2 = AssocTuple('a'=>1, 'b'=>2)
@test isa(t2, AssocTuple{Char,Int})

# Constructing from a Pair vs. constructing from an iterator
t1 = AssocTuple(('a'=>1) => ('b'=>2))
@test isa(t1, AssocTuple{Pair{Char,Int}, Pair{Char,Int}})
t2 = AssocTuple(('a'=>1), ('b'=>2))
@test isa(t2, AssocTuple{Char,Int})
t3 = AssocTuple((('a'=>1), ('b'=>2)))
@test isa(t3, AssocTuple{Char,Int})
t4 = AssocTuple(Pair{Char,Int}[('a'=>1), ('b'=>2)])
@test isa(t4, AssocTuple{Char,Int})
t5 = AssocTuple((('a',1), ('b',2)))
@test isa(t5, AssocTuple{Char,Int})
t6 = AssocTuple([('a',1), ('b',2)])
@test isa(t6, AssocTuple{Char,Int})

# Type properties
t0 = AssocTuple{Char,Int}()
@test eltype(t0) === Pair{Char,Int}
t0 = AssocTuple()
@test eltype(t0) === Pair{Any,Any}
@test eltype(t1) === Pair{Pair{Char,Int}, Pair{Char,Int}}
@test eltype(t2) === Pair{Char,Int}

# Object properties
@test isempty(t0)
@test !isempty(t1)
@test !isempty(t2)
@test length(t0) == 0
@test length(t1) == 1
@test length(t2) == 2

# Iterators
@test itercmp(t0, Pair{Char,Int}[])
@test itercmp(t1, Pair{Pair{Char,Int}, Pair{Char,Int}}[('a'=>1) => ('b'=>2)])
@test itercmp(t2, Pair{Char,Int}[('a'=>1), ('b'=>2)])

@test itercmp(keys(t0), Char[])
@test itercmp(keys(t1), Pair{Char,Int}['a'=>1])
@test itercmp(keys(t2), Char['a', 'b'])

@test itercmp(values(t0), Int[])
@test itercmp(values(t1), Pair{Char,Int}['b'=>2])
@test itercmp(values(t2), Int[1, 2])

@test itercmp(eachindex(t0), keys(t0))
@test itercmp(eachindex(t1), keys(t1))
@test itercmp(eachindex(t2), keys(t2))

# Duplicate keys
u1 = AssocTuple{Char,Int}([('a',1), ('a',2), ('b',2), ('a',1)])
@test itercmp(u1, t2)
u2 = AssocTuple{Char,Int}('a'=>1, 'a'=>2, 'b'=>2, 'a'=>1)
@test itercmp(u2, t2)
u3 = AssocTuple([('a',1), ('a',2), ('b',2), ('a',1)])
@test itercmp(u3, t2)
u4 = AssocTuple('a'=>1, 'a'=>2, 'b'=>2, 'a'=>1)
@test itercmp(u4, t2)

# Element-wise access

@test_throws KeyError t0['a']
@test t1['a'=>1] == ('b'=>2)
@test t2['a'] == 1
@test t2['b'] == 2
@test_throws KeyError t2['c']
