include("Utility.jl")
include("simulate.jl")

using Base.Test
import OdeUtility: poly2deq
import Utility: csvWrite

# ---------------------------------------------------------------------- 
function lpf1()
  t = [0:0.1:10.0;]
  noms = [1.0]
  dens = [1.0, 10.0]
  ini = [0.0, 0.0]

  td, tr = 0.0, 1.0
  step(t)  = 0.5 - cospi(clamp((t-td)/tr, 0, 1))/2 
  dstep(t) = pi/tr*sinpi(clamp((t-td)/tr, 0, 1))/2

  h = poly2deq([dstep], noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  return t, y1, y2
end
# ---------------------------------------------------------------------- 
function hpf1()
  t = [0:0.1:10.0;]
  noms = [1.0, 10.0]
  dens = [1.0, 0.1]
  ini = [0.0, 0.0]

  td, tr = 0.0, 1.0
  step(t)  = 0.5 - cospi(clamp((t-td)/tr, 0, 1))/2 
  dstep(t) = pi/tr*sinpi(clamp((t-td)/tr, 0, 1))/2
  
  h = poly2deq([dstep], noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  return t, y1, y2
end
# ---------------------------------------------------------------------- 
function run_top()
  t, y1, y2 = lpf1()
  csvWrite("a.csv", "w", [t y1 y2]')
end
# @testset "Foo Tests" begin
#   @test 1+1 == 2
#   @test 1+2 == 3
#   @test 2+2 == 4
# end
