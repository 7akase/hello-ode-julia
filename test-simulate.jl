include("simulate.jl")

using Base.Test
import OdeUtility: poly2deq

# ---------------------------------------------------------------------- 
function lpf1()
  t = [0:0.1:100;]
  noms = [1.0]
  dens = [1.0, 10.0]
  ini = [0.0, 0.1]

  # h = poly2deq((t->2.0<=t<3.0 ? 1.0 : 0.0), noms, dens)
  h = poly2deq([sin], noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  return t, y1, y2 
end

function run_top()
  t, y1, y2 = lpf1()
  open("a.csv", "w") do fp
    for i in 1:length(t)
      println(fp, "$(t[i])\t $(y1[i])\t $(y2[i])")
    end
  end
end
# @testset "Foo Tests" begin
#   @test 1+1 == 2
#   @test 1+2 == 3
#   @test 2+2 == 4
# end
