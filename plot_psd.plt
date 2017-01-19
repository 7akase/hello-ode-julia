#!/usr/bin/gnuplot -p

plot 'psd.csv' using ($1):(20*log10($2)) w l
set logscale x
set grid
replot
