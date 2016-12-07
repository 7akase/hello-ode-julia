module Utility
# ----------------------------------------------------------------------  
import Base: $, *
export fst, snd
export zipWith

fst(x) = begin a, b = x; return a; end
snd(x) = begin a, b = x; return b; end

($)(f :: Function, x) = f(x)
(∘)(g :: Function, f :: Function) = x -> g(f(x))

zipWith(f,a,b) = map(f, zip(a,b))

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
export sigmoid, step

sigmoid(x, a) = 1 / (1 + exp(-a*x))
step(t, td, tr) = 0.5 - cospi(clamp((t-td)/tr, 0, 1))/2
# ----------------------------------------------------------------------  
#  array and matrix
import Base.convert
export convert

convert{T}(::Type{Array{T,2}}, aa :: Array{Array{T,1},1}) = hcat(aa...)'

# ----------------------------------------------------------------------  
end  # module
