module Utility
# ----------------------------------------------------------------------  
import Base: $, *
export fst, snd
export zipWith
export filter_rec

fst(x) = begin a, b = x; return a; end
snd(x) = begin a, b = x; return b; end

($)(f :: Function, x) = f(x)
(∘)(g :: Function, f :: Function) = x -> g(f(x))

zipWith(f,a,b) = map(f, zip(a,b))

function filter_rec(op, xss)
  filter_rec(op, xss, [])
end

function filter_rec(op, xss, ys)
  if isempty(xss)
    return ys
  else
    for i in xss
      if op(i)
        push!(ys, i)
      end
      if isa(i, AbstractArray)
        filter_rec(op, i, ys)
      end
    end
    return ys
  end
end

# ----------------------------------------------------------------------  
export csvWrite

function csvWrite{T}( filename, mode, vec :: Array{T,2}
                    ; delim="\t")
  open(filename, mode) do fp
    for i in 1:snd(size(vec))
      println(fp, join(vec[:,i], delim))
    end
  end
end

# ----------------------------------------------------------------------  
#  basic functions
export sigmoid, step_cos

sigmoid(x, a) = 1 / (1 + exp(-a*x))
step_cos(t, td, tr) = 0.5 - cospi(clamp((t-td)/tr, 0, 1))/2

# ----------------------------------------------------------------------  
#  array and matrix
import Base.convert
export convert

convert{T}(::Type{Array{T,2}}, aa :: Array{Array{T,1},1}) = hcat(aa...)'

# ----------------------------------------------------------------------  
end  # module
