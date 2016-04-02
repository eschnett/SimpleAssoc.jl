module SimpleAssoc

import Base: copy, delete!, done, eachindex, eltype, empty!, get!,
    get, getkey, haskey, isempty, keys, length, next, pop!, setindex!,
    start, values

export AssocArray, AssocTuple
# export pop, push, setindex

################################################################################

"""
    type AssocArray{K,V}

A simple associative collection based on (unsorted) arrays

An `AssocArray` is a simple associative collection. Functionally it is
equivalent to a `Dict`. The major difference is that an `AssocArray`
uses a simpler internal representation, based on an unsorted array.
This can be faster than a `Dict` if the collection is small, or if the
collection is searched only infrequently.
"""
type AssocArray{K,V} <: Associative{K,V}
    elems::Vector{Pair{K,V}}
    AssocArray() = new(Pair{K,V}[])
    AssocArray(elem::Pair{K,V}) = new([elem])
    AssocArray(elems::Dict{K,V}) = new(collect(elems))
    AssocArray(a::AssocArray) = new(copy(a.elems))
end

function (::Type{AssocArray{K,V}}){K,V}(elem::Pair)
    AssocArray{K,V}(Pair{K,V}(K(elem.first) => V(elem.second)))
end
(::Type{AssocArray{K,V}}){K,V}(iter) = AssocArray{K,V}(Dict{K,V}(iter))
(::Type{AssocArray{K,V}}){K,V}(elems::Pair...) = AssocArray{K,V}(elems)

(::Type{AssocArray}){K,V}(elem::Pair{K,V}) = AssocArray{K,V}(elem)
function (::Type{AssocArray})(iter)
    dict = Dict(iter)
    K = keytype(dict)
    V = valtype(dict)
    AssocArray{K,V}(dict)
end
(::Type{AssocArray})(elems::Pair...) = AssocArray(elems)
(::Type{AssocArray}){K,V}(a::AssocArray{K,V}) = AssocArray{K,V}(a)

copy(a::AssocArray) = AssocArray(a)

eltype{K,V}(::AssocArray{K,V}) = Pair{K,V}

isempty(a::AssocArray) = isempty(a.elems)
length(a::AssocArray) = length(a.elems)

start(a::AssocArray) = start(a.elems)
done(a::AssocArray, st) = done(a.elems, st)
next(a::AssocArray, st) = next(a.elems, st)

immutable AssocArrayIter{I,K,V}
    arr::AssocArray{K,V}
end
start(ai::AssocArrayIter) = start(ai.arr.elems)
done(ai::AssocArrayIter, st) = done(ai.arr.elems, st)
function next{I}(ai::AssocArrayIter{I}, st)
    it, st = next(ai.arr.elems, st)
    it[I], st
end
keys{K,V}(a::AssocArray{K,V}) = AssocArrayIter{1,K,V}(a)
values{K,V}(a::AssocArray{K,V}) = AssocArrayIter{2,K,V}(a)
eachindex(a::AssocArray) = keys(a)

empty!(a::AssocArray) = empty!(a.elems)

function pop!(a::AssocArray)
    if isempty(a)
        throw(BoundsError(a))
    end
    pop!(a.elems)
end

function getkey(a::AssocArray, k, d)
    for el in a.elems
        if el.first === k
            return el.first
        end
    end
    d
end

function get(a::AssocArray, k, d)
    for el in a.elems
        if el.first === k
            return el.second
        end
    end
    d
end

function get!(a::AssocArray, k, d)
    for el in a.elems
        if el.first === k
            return el.second
        end
    end
    a[k] = d
end

function setindex!{K,V}(a::AssocArray{K,V}, v, k)
    for i in eachindex(a.elems)
        if a.elems[i].first === k
            a.elems[i] = Pair{K,V}(K(k), V(v))
            return v
        end
    end
    push!(a.elems, Pair{K,V}(K(k), V(v)))
    v
end

function delete!(a::AssocArray, k)
    for i in eachindex(a.elems)
        if a.elems[i].first === k
            if i < length(a.elems)
                a.elems[i] = pop!(a.elems)
            else
                pop!(a.elems)
            end
            return a
        end
    end
    a
end

################################################################################

# immutable UnsafeAssertIsUnique end

"""
    type AssocTuple{K,V,N}

A simple associative collection based on (unsorted) tuples

An `AssocTuple` is a simple associative collection. Functionally it is
equivalent to a immutable `Dict`. The major difference is that an
`AssocTuple` uses a simpler internal representation, based on an
unsorted tuple. This can be faster than a `Dict` if the collection is
small, or if the collection is searched only infrequently.
"""
immutable AssocTuple{K,V,N} <: Associative{K,V}
    elems::NTuple{N, Pair{K,V}}
    function AssocTuple()
        @assert N == 0
        new(())
    end
    function AssocTuple(elem::Pair{K,V})
        @assert N == 1
        new((elem,))
    end
    function AssocTuple(elems::Dict{K,V})
        @assert N == length(elems)
        new((elems...))
    end
    # function AssocTuple(::Type{UnsafeAssertIsUnique},
    #                     elems::NTuple{N, Pair{K,V}})
    #     new(elems)
    # end
end

function (::Type{AssocTuple{K,V,N}}){K,V,N}(elem::Pair)
    AssocTuple{K,V,N}(K(elem.first) => V(elem.second))
end

(::Type{AssocTuple{K,V}}){K,V}() = AssocTuple{K,V,0}()
(::Type{AssocTuple{K,V}}){K,V}(elem::Pair) = AssocTuple{K,V,1}(elem)
function (::Type{AssocTuple{K,V}}){K,V}(iter)
    dict = Dict{K,V}(iter)
    N = length(dict)
    AssocTuple{K,V,N}(dict)
end
(::Type{AssocTuple{K,V}}){K,V}(elems::Pair...) = AssocTuple{K,V}(elems)

(::Type{AssocTuple})() = AssocTuple{Any,Any}()
(::Type{AssocTuple}){K,V}(elem::Pair{K,V}) = AssocTuple{K,V,1}(elem)
function (::Type{AssocTuple})(iter)
    dict = Dict(iter)
    K = keytype(dict)
    V = valtype(dict)
    N = length(dict)
    AssocTuple{K,V,N}(dict)
end
(::Type{AssocTuple})(elems::Pair...) = AssocTuple(elems)
 
eltype{K,V}(::AssocTuple{K,V}) = Pair{K,V}

isempty(a::AssocTuple) = isempty(a.elems)
length(a::AssocTuple) = length(a.elems)

start(a::AssocTuple) = start(a.elems)
done(a::AssocTuple, st) = done(a.elems, st)
next(a::AssocTuple, st) = next(a.elems, st)

immutable AssocTupleIter{I,K,V}
    arr::AssocTuple{K,V}
end
start(ai::AssocTupleIter) = start(ai.arr.elems)
done(ai::AssocTupleIter, st) = done(ai.arr.elems, st)
function next{I}(ai::AssocTupleIter{I}, st)
    it, st = next(ai.arr.elems, st)
    it[I], st
end
keys{K,V}(a::AssocTuple{K,V}) = AssocTupleIter{1,K,V}(a)
values{K,V}(a::AssocTuple{K,V}) = AssocTupleIter{2,K,V}(a)
eachindex(a::AssocTuple) = keys(a)

# function pop{K,V,N}(a::AssocTuple{K,V,N})
#     if isempty(a)
#         throw(BoundsError(a))
#     end
#     a.elems[end], AssocTuple{K,V,N-1}(UnsafeAssertIsUnique, a.elems[1:end-1])
# end

function getkey(a::AssocTuple, k, d)
    for el in a.elems
        if el.first === k
            return el.first
        end
    end
    d
end

function get(a::AssocTuple, k, d)
    for el in a.elems
        if el.first === k
            return el.second
        end
    end
    d
end

# function get!(a::AssocTuple, k, d)
#     for el in a.elems
#         if el.first === k
#             return el.second
#         end
#     end
#     a[k] = d
# end

# function setindex!(a::AssocTuple, v, k)
#     for i in eachindex(a.elems)
#         if a.elems[i].first === k
#             a.elems[i] = k => v
#             return v
#         end
#     end
#     push!(a.elems, k => v)
#     v
# end

# push!(a, elem) = a[elem.first] = elem.second

# function delete!(a::AssocTuple, k)
#     for i in eachindex(a.elems)
#         if a.elems[i].first === k
#             if i < length(a.elems)
#                 a.elems[i] = pop!(a.elems)
#             else
#                 pop!(a.elems)
#             end
#             return a
#         end
#     end
#     a
# end

end
