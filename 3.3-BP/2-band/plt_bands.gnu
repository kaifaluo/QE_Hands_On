## ===
set terminal pngcairo dashed color enhanced \
             font "arial,10" fontscale 1.0 \
             size 400, 300
set output 'bands.png'

set style data lines
unset key
set xrange [0:2.6055]
set ylabel "Energy [eV]"
set yrange [-4:4]
set xtics ("G" 0.0000, "Z" 0.3100, "T" 0.7573, "C" 1.1375, "Z" 1.7215, "R" 2.1044, 'G' 2.6055 ) ## 3D cubic
set grid

## ===
 plot 'bands.gnu' u 1:(column(2) - 7.6576) w l lt -1
