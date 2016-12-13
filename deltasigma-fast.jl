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
Nsig = Nfft / Nwaves
Tfft = Ts * Nfft
Tsig = Tfft / Nwaves
fsig = 1.0 / Tsig

fin(t) = 0.1 .* sin(2pi*fsig*t)
stepDac(t) = dDac 

Tsim = Ts * Nfft

ts = Tsig / Nfft * [0:Nfft-1;]

# FW-filter response
t, y0 = ODE.ode23s(G(fin), a0_in, ts)
y0 = y0[(x -> x == 0).(indexin(t, setdiff(t, ts)))]  # calc all resp
y0 = getindex(y0, [rem(i*Nwaves, Nfft)+1 for i in 0:Nfft-1])  # realloc
ys0 = [a[1] for a in y0]

# DAC response
a0_dac = a0_in
a0_dac[1] = dDac
t, yDac = ODE.ode23s(G(stepDac), a0_dac, [0.0,Ts])
yDac = yDac[end][1]

# run
vs = zeros(ys0)
ys = zeros(ys0)
y = ys0[1]
ys[1] = y
prevD = [-1, -1]

print("progress |")
for i in 2:length(ys0)
  if rem(i, div(length(ys0), 40)) == 0
    print("*")
  end
  vs[i] = y > 0 ? 1 : -1
  currentD = runDT(prevD, vs[i])
  y = y - (currentD[2] - prevD[2])*yDac + ys0[i] - ys0[i-1]
  ys[i] = y
end

hann(n) = [0.5 - 0.5cospi(2x) for x in [0:n-1;]/(n-1)]

psd = abs(fft(hann(Nfft) .* vs))[1:Nfft÷2]
psd_inband = psd[1:convert(Int, Nfft/2/osr)]

fs = [0:Nfft÷2-1;]/Nfft/Ts
csvWrite("psd.csv", "w", [fs psd]')
