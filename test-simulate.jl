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
  noms = [1.0, 1e+1]
  dens = [1.0, 1e-5]
  vi = zeros(noms)
  vo = zeros(dens)[1:end-1]
  ini = [vo; vi]

  td, tr = 0.0, 1.0
  step(t)   =   0.5    -cospi(clamp((t-td)/tr, 0, 1))/2 
  dstep(t)  =  pi/tr   *sinpi(clamp((t-td)/tr, 0, 1))/2
  ddstep(t) = (pi/tr)^2*cospi(clamp((t-td)/tr, 0, 1))/2 # NG 
  h = poly2deq([dstep, ddstep], noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  y3 = [ a[3] for a in y ]
  return t, y1, y2, y3
end
# ---------------------------------------------------------------------- 
function run_top()
  t, y1, y2 = lpf1()
  csvWrite("lpf1.csv", "w", [t y1 y2]')
  t, y1, y2, y3 = hpf1()
  csvWrite("hpf1.csv", "w", [t y1 y2 y3]')
end
# @testset "Foo Tests" begin
#   @test 1+1 == 2
#   @test 1+2 == 3
#   @test 2+2 == 4
# end
