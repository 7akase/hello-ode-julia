include("Utility.jl")
include("simulate.jl")

using Base.Test
using ForwardDiff
import OdeUtility: poly2deq
import Utility: csvWrite
import Calculus: derivative
# ---------------------------------------------------------------------- 
function lpf1()
  t = [0:0.1:10.0;]
  noms = [1.0]
  dens = [1.0, 10.0]
  ini = [0.0, 0.0]

  td, tr = 0.0, 1.0
  step(t)  = 0.5 - cospi(clamp((t-td)/tr, 0, 1))/2 

  h = poly2deq(step, noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  return t, y1, y2
end
# ---------------------------------------------------------------------- 
function hpf1()
  t = [0:0.1:10.0;]
  noms = [0.0, 10.0]
  dens = [1.0, 10.0]
  vi = zeros(noms)
  vo = zeros(dens)[1:end-1]
  ini = [vo; vi]

  td, tr = 0.0, 1.0
  f0(t) = 0.5-cospi(clamp((t-td)/tr, 0, 1))/2 
  h = poly2deq(f0, noms, dens)
  t, y = ODE.ode23s(h, ini, t)
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  return t, y1, y2
end
# ---------------------------------------------------------------------- 
function hpf1_step()
  t1r = [0.0:0.1: 1.0;]
  t1  = [1.0:0.1: 5.0;]
  t2r = [5.0:0.1: 6.0;]
  t2  = [6.0:0.1:10.0;]
  noms = [0.0, 10.0]
  dens = [1.0, 10.0]
  vi = zeros(noms)
  vo = zeros(dens)[1:end-1]
  ini = [vo; vi]

  td, tr = 0.0, 1.0
  f0(t) = 0.5-cospi(clamp((t-td)/tr, 0, 1))/2 
  
  h = poly2deq(f0, noms, dens)
  tt, y = ODE.ode23s(h, ini, t1r)
  t  = tt
  y1 = [ a[1] for a in y ]
  y2 = [ a[2] for a in y ]
  println("$(length(t)), $(length(y1)), $(length(y2))")

  h = poly2deq(t -> 0, noms, dens)
  tt, y = ODE.ode23s(h, y[end], t1)
  t  = [t;tt]
  y1 = [y1;[ a[1] for a in y ]]
  y2 = [y2;[ a[2] for a in y ]]
  println("$(length(t)), $(length(y1)), $(length(y2))")
  
  h = poly2deq(t->f0(t-5.0), noms, dens)
  tt, y = ODE.ode23s(h, y[end], t2r)
  t  = [t;tt]
  y1 = [y1;[ a[1] for a in y ]]
  y2 = [y2;[ a[2] for a in y ]]
  println("$(length(t)), $(length(y1)), $(length(y2))")

  h = poly2deq(t->f0(t-5.0), noms, dens)
  tt, y = ODE.ode23s(h, y[end], t2)
  t  = [t;tt]
  y1 = [y1;[ a[1] for a in y ]]
  y2 = [y2;[ a[2] for a in y ]]
  println("$(length(t)), $(length(y1)), $(length(y2))")

  return t, y1, y2
end
# ---------------------------------------------------------------------- 
function run_top()
  t, y1, y2 = lpf1()
  csvWrite("lpf1.csv", "w", [t y1 y2]')
  t, y1, y2 = hpf1()
  csvWrite("hpf1.csv", "w", [t y1 y2]')
  t, y1, y2 = hpf1_step()
  println("$(length(t)), $(length(y1)), $(length(y2))")
  csvWrite("hpf1_step.csv", "w", [t y1 y2]')
end
# @testset "Foo Tests" begin
#   @test 1+1 == 2
#   @test 1+2 == 3
#   @test 2+2 == 4
# end
