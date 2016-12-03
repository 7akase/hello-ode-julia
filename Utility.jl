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
end  # module
