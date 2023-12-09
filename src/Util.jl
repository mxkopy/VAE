using Flux, JSON
using Flux.ChainRulesCore: @ignore_derivatives as @ignore

macro register( struct_declaration::Expr )
    T = struct_declaration.args[2]
    while !(T isa Symbol)
        T = T.args[1]
    end
    return eval(:(
        $struct_declaration;
        Flux.@functor $T;
    ))
end

@register struct Device{P <: Number, D}
    layer
    function Device{P, D}(layer) where {P, D}
        function to(x::T)::T where T x end
        function to(x::AbstractArray) x .|> P |> D end
        new{P, D}( fmap(to, layer) )
    end
end

function (d::Device{P, D})(x::AbstractArray{T}) where {T, P <: Number, D}
    X = @ignore x .|> P |> D
    return d.layer(X)
end

function (d::Device{P, D})(x::T) where {T, P <: Number, D}
    X = @ignore x |> P |> D
    return d.layer(X)
end

@register struct PermuteInput
    permutations::NTuple{N, Int} where N
    layer
    PermuteInput(permutations::NTuple, layer) = new(permutations, layer)
    PermuteInput(permutations::NTuple)        = layer -> new(permutations, layer)
    PermuteInput(permutations...)             = layer -> new(permutations, layer)
end
function (c::PermuteInput)(data::AbstractArray{T, N})::AbstractArray{T, N} where {T <: Number, N}
    return c.layer(permutedims(data, c.permutations))
end

@register struct PermuteOutput
    permutations::NTuple{N, Int} where N
    layer
    PermuteOutput(permutations::NTuple, layer) = new(permutations, layer)
    PermuteOutput(permutations::NTuple)        = layer -> new(permutations, layer)
    PermuteOutput(permutations...)             = layer -> new(permutations, layer)
end
function (c::PermuteOutput)(data::AbstractArray{T, N})::AbstractArray{T, N} where {T <: Number, N}
    return permutedims(c.layer(data), c.permutations)
end


