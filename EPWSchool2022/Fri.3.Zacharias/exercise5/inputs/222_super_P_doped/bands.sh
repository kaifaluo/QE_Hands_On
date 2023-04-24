PATHQE=~/codes/q-e_latest_for_merge/
$PATHQE/bin/plotband.x unfold_weights.dat < spectral_weights.in > spectral_weights.out
$PATHQE/bin/plotband.x frequencies.dat < energies.in > energies.out
#sed -i '/^$/d' spectral_weights.xmgr # remove empty lines 
sed -i '/^\s*$/d' spectral_weights.dat
sed -i '/^\s*$/d' energies.dat
paste energies.dat spectral_weights.dat > tmp
awk '{print $1,$2,$4}' tmp > energies_weights.dat
rm tmp
