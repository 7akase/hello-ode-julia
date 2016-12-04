module Utility
# ----------------------------------------------------------------------  
import Base: $, *
export fst, snd
export zipWith

fst(x) = begin a, b = x; return a; end
snd(x) = begin a, b = x; return b; end

($)(f :: Function, x) = f(x)
(*)(g :: Function, f :: Function) = x -> g(f(x))

zipWith(f,a,b) = map(f, zip(a,b))

# ----------------------------------------------------------------------  
export csvWrite

function csvWrite(filename, mode, vec; delim="\t")
  open(filename, mode) do fp
    for i in 1:snd(size(vec))
      println(fp, join(vec[:,i], delim))
    end
  end
end

# ----------------------------------------------------------------------  
#  basic functions

sigmoid(x, a) = 1 / (1 + exp(-a*x))

# ----------------------------------------------------------------------  
end  # module
