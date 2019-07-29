
import Base: promote_rule, convert, real
import IntervalArithmetic: Interval

export convert, real
export NumberInterval, IndeterminateException

"""
    IndeterminateException()

Exception raised when the result of a numerical operation on a `NumberInterval`
is indeterminate.
"""
struct IndeterminateException <: Exception end


"""
    NumberInterval(lo, hi)

Interval which behaves like a number under standard arithmetic operations and
comparisons and raises an `IndeterminateException` when the results of these
operations cannot be rigorously determined.
"""
struct NumberInterval{T <: Number} <: Number
    lo::T
    hi::T
    NumberInterval(lo, hi) = hi >= lo ? new{typeof(lo)}(lo, hi) : error("invalid interval ($lo , $hi)")
end

NumberInterval(a::Interval) = NumberInterval(a.lo, a.hi)
(::Type{NumberInterval{T}})(a::NumberInterval{T}) where T = a

Interval(a::NumberInterval) = Interval(a.lo, a.hi)

NumberInterval(a) = NumberInterval(Interval(a))
NumberInterval{T}(a) where T = NumberInterval(Interval{T}(a))

real(a::NumberInterval{T}) where {T <: Real} = a

_promote_interval_type(::Type{Interval{T}}) where T = NumberInterval{T}
_promote_interval_type(a::Type) = a

promote_rule(::Type{NumberInterval{T}}, b::Type) where T = _promote_interval_type(promote_rule(Interval{T}, b))
