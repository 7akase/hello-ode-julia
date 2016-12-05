include("Utility.jl")
module OdeUtility
# ---------------------------------------------------------------------- 
# ---------------------------------------------------------------------- 
using ForwardDiff

import ODE
import Utility: fst, snd
import Calculus: derivative
export poly2deq
# ---------------------------------------------------------------------- 

function poly2deq( f0 :: Function
                 , ns = [1.]
                 , ds = [1., 10.]
                 )
  f = Array{Function}(length(ns))
  for i in 1:length(ns)
    if i == 1
      f[1] = derivative(f0)
    else
      f[i] = derivative(f[i-1])
    end
  end
  poly2deq(f, ns, ds)
end

function poly2deq( f :: Array{Function,1}
                 , ns = [1.]
                 , ds = [1., 10.]
                 )
  function H(t, vec)
    length(ds) >= 2 || error("dens must have >= 2 elements, but $(length(ds))")
    length(vec) == length(ds) + length(ns) - 1 || error("vec size doesn't match (must be $(length(ds)+length(ns)-1), but $(length(vec)) )")
    length(f) == length(ns) || error("length(fx) must be $(length(ns))")
    vo = collect(take(vec, length(ds)-1))
    vi = collect(drop(vec, length(ds)-1))
    svi = f $ t
    svo = [vo[2:end]; (sum(ns.*vi) - sum(ds[1:end-1].*vo))/ds[end]]
    return [svo; svi]
  end
  return H
end
# ----------------------------------------------------------------------  
end  # module
