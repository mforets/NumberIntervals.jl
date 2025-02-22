
import Base: <, iszero, ==, <=, >=, sign, signbit, isinteger, isfinite
export <, iszero, ==, <=, >=, sign, signbit, isinteger, isfinite

function isinteger(a::NumberInterval)
    if floor(a) ≺ a ≺ ceil(a)
        return false
    elseif issingleton(a)
        #NOTE given the previous result, singletons must contain single integers
        return true
    end
    throw(IndeterminateException(a))
end

function isfinite(a::NumberInterval)
    # per IEEE standard, intervals cannot contain infinities
    if !isempty(a) && !isnan(a)
        return true
    end
    throw(IndeterminateException(a))
end

for (numberf, setf) in ((:<, :strictprecedes), (:<=, :precedes))
    @eval function $numberf(a::NumberInterval, b::NumberInterval)
        if $setf(a, b)
            return true
        elseif $setf(b, a)
            return false
        end
        throw(IndeterminateException((a, b)))
    end
end

>=(a::NumberInterval, b::NumberInterval) = b <= a

function iszero(a::NumberInterval)
    if !contains_zero(a)
        return false
    end
    if a ⊆ zero(typeof(a))
        return true
    end
    throw(IndeterminateException(a))
end

function ==(a::NumberInterval, b::NumberInterval)
    if isnan(a) || isnan(b)
        return false
    elseif isdisjoint(a, b)
        return false
    elseif issingleton(a) && issingleton(b) && a ⊆ b
        return true
    end
    throw(IndeterminateException((a, b)))
end

function sign(a::NumberInterval)
    z = zero(typeof(a))
    if strictprecedes(a, z)
        return -1
    elseif strictprecedes(z, a)
        return +1
    elseif a ⊆ z
        return  0
    end
    throw(IndeterminateException(a))
end

function signbit(a::NumberInterval)
    z = zero(typeof(a))
    if strictprecedes(a, z)
        return true
    elseif precedes(z, a)
        return false
    end
    throw(IndeterminateException(a))
end
