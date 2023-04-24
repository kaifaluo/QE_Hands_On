set terminal postscript eps color enhanced size 3.7,2.7 font 'Arial-Bold'
set output "ph_unfolding_P_doped_333.eps"
set ytics 100 offset 0.8,0
set xrange [0:5.3534]
set yrange [0:550]
unset xtics
set key left
set format y "%.0f"
set xlabel "wave vector" offset 1.1,-1.3
set ylabel "Frequency (cm^{-1})"
set arrow from 1.0607,0 to 1.0607,550 nohead
set arrow from 1.4142,0 to 1.4142,550 nohead
set arrow from 2.4142,0 to 2.4142,550 nohead
set arrow from 3.2802,0 to 3.2802,550 nohead
set arrow from 4.1463,0 to 4.1463,550 nohead
set arrow from 4.6463,0 to 4.6463,550 nohead
set arrow from 5.3534,0 to 5.3534,550 nohead
set label "{/Symbol G}" at -0.015,-30
set label "K" at 1.05,-30
set label "X" at 1.40,-30
set label "{/Symbol G}" at 2.4,-30
set label "L" at 3.265,-30
set label "X" at 4.000,-30
set label "W" at 4.500,-30
set label "L" at 5.250,-30
#
set label "TA" at 3.6,215 tc rgb "white" front
set label "LA" at 3.5,352 tc rgb "white" front
set label "LO" at 3.6,432 tc rgb "white" front
set label "TO" at 3.6,502 tc rgb "white" front
set style data linespoints

set view map
set colorbox horizontal user origin 0.15,0.88 size 0.35,0.03
set cbtics 0.25 offset 0.0,2.4,0
set pm3d interp 1,20
set cbrange[0.0:1.0]
set format y "%.1f"

set palette defined (0.1 '#000004', 0.2 '#1c1044', 0.5 '#4f127b', 1 '#812581', 2 '#b5367a', 3 '#e55964', 4 '#fb8761', 5 '#fec287', 6 '#fbfdbf')

splot "spectral_function_333_P_doped.dat" u ($1):($2):($3)  not w pm3d,\
     "si_ph_dispersion_333.xmgr" u ($1):($2):($3) not  w l lw 1 lc rgb "white"


exit

