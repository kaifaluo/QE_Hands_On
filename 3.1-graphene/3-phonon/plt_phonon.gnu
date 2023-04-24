## ===
set terminal pngcairo color enhanced \
             font "arial,10" fontscale 1.0 \
             size 400, 300
set output 'ph.png'

set style data lines
unset key
set title "phonon dispersion"
set ylabel "Frequency [cm-1]"
set xtics ("G" 0, "M" 0.5574, "K" 0.8907, "G" 1.5573)
set xrange [0:1.5573]

## ===
plot for [i=2:7]  "./graphene.freq.gp" using 1:(column(i)) with lines lt -1, 0 lt 1
