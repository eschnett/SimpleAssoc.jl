module SimpleAssoc

import Base: copy, delete!, done, eachindex, eltype, empty!, get!,
    get, getkey, haskey, isempty, keys, length, next, pop!, setindex!,
    start, values

export AssocArray, AssocTuple

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

end
