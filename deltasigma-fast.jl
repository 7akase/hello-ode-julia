include("Utility.jl")
include("OdeUtility.jl")
include("Debug.jl")

using Base.Test
using ForwardDiff
using Utility
using Debug
import OdeUtility: poly2deq
import Utility: csvWrite
import Calculus: derivative
import Utility: step_cos
importall Debug

# ---------------------------------------------------------------------- 
# Configuration
# ---------------------------------------------------------------------- 
## Top Level
Ts = 1.0
osr = 256

## FW-filter
noms = [1.0, 2.0]
dens = [1.0, 100.0]
G(f) = poly2deq(f :: Function, noms, dens)

## FB-filter
function runDT(prev, v) 
  zv, zfb = prev
  [v, 2v-zv+zfb]
end

## DAC 
Ndac = 8
dDac = 2 / 2^Ndac

vi = zeros(noms)
vo = zeros(dens)[1:end-1]
a0_in  = [vo; vi]

Nfft = 2^14

# ---------------------------------------------------------------------- 
# Prepare 
# ---------------------------------------------------------------------- 

Nwaves = 23
Tfft = Ts * Nfft
Nsig = Nfft ÷ Nwaves
Tsig = Tfft / Nwaves
fsig = 1.0 / Tsig
# 2pi*fsig*A*Ts = dDac  <=>  A = dDac / 2pi fsig Ts
fin(t) =  (dDac / pi * osr ) .* sinpi(2*fsig*t)
stepDac(t) = dDac * step_cos(t, 0, Ts*0.005) 

Tsim = Ts * Nfft

ts = [0:Nfft-1;] .* Ts
ts_folded = Tsig / Nfft * [0:Nfft-1;]

# FW-filter response
t, y0 = ODE.ode23s(G(fin), a0_in, ts_folded)
y0 = y0[(x -> x == 0).(indexin(t, setdiff(t, ts_folded)))]  # calc all resp
y0 = getindex(y0, [rem(i*Nwaves, Nfft)+1 for i in 0:Nfft-1])  # realloc
ys0 = [a[1] for a in y0]

# DAC response
a0_dac = a0_in
a0_dac[1] = 1.0 
t, yDac = ODE.ode23s(G(t -> 0.0), a0_dac, ts)
yDac = dDac .* yDac[(x -> x == 0).(indexin(t, setdiff(t, ts)))]
yDac = [a[1] for a in yDac]

# run
us = fin(ts)
vs = -1 .* ones(ys0)
ys = ys0
prevD = [-1, -1]

print("progress |")
for i in 2:length(ys0)
  if rem(i, div(length(ys0), 40)) == 0
    print("*")
  end
  vs[i] = ys[i-1] > 0 ? 1 : -1  # quantizer
  currentD = runDT(prevD, vs[i])  # Discrete Transfer FunctionA
  dfb = currentD[2] - prevD[2]
  ys[i:end] = ys[i:end] - dfb .* yDac[1:length(ys0)-i+1]
  # y = y - (currentD[2] - prevD[2])*yDac + ys0[i] - ys0[i-1]
end

hann(n) = [0.5 - 0.5cospi(2x) for x in [0:n-1;]/(n-1)]

psd_u = abs(fft(hann(Nfft) .* us))[1:Nfft÷2]
psd = abs(fft(hann(Nfft) .* vs))[1:Nfft÷2]
psd_inband = psd[1:convert(Int, Nfft/2/osr)]

fs = [1:Nfft÷2;]/Nfft/Ts
csvWrite("psd.csv", "w", [fs psd psd_u]')
csvWrite("psd_t.csv", "w", [ts vs us ys yDac]')
