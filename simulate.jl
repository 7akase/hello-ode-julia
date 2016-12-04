include("Utility.jl")
module OdeUtility
# ---------------------------------------------------------------------- 
# ---------------------------------------------------------------------- 
import ODE
import Utility: fst, snd
export poly2deq
# ---------------------------------------------------------------------- 

function poly2deq( f
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
