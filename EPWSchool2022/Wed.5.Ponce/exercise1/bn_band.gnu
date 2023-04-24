set style data dots
set nokey
set xrange [0: 7.79753]
set yrange [ -0.50390 : 12.28127]
set arrow from  1.73767,  -0.50390 to  1.73767,  12.28127 nohead
set arrow from  2.35203,  -0.50390 to  2.35203,  12.28127 nohead
set arrow from  4.19511,  -0.50390 to  4.19511,  12.28127 nohead
set arrow from  5.69997,  -0.50390 to  5.69997,  12.28127 nohead
set arrow from  6.92869,  -0.50390 to  6.92869,  12.28127 nohead
set xtics ("G"  0.00000,"X"  1.73767,"U|K"  2.35203,"G"  4.19511,"L"  5.69997,"W"  6.92869,"X"  7.79753)
 plot "bn_band.dat"
