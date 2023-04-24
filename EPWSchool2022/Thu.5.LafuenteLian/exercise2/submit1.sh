#!/bin/bash
#SBATCH -J myjob              # Job name
#SBATCH -p small              # Queue (partition) name
#SBATCH -N 1                  # Total # of nodes
#SBATCH --ntasks-per-node 56
#SBATCH -t 01:00:00           # Run time (hh:mm:ss)
#SBATCH -A EPSchool2022
#SBATCH --reservation=EPSchoolDay4

# echo loaded modules, current directory, and starting time
module list
pwd
date

# export the path which contains executable file
export PATHQE=/work2/06868/giustino/EP-SCHOOL/q-e-epw-2022-polaron-master/


# run jobs

# epw1: g(Re,Rp)
ibrun -np 54 $PATHQE/bin/epw.x -npool 54 -input lif.epw1.in > lif.epw1.out

# epw2: polaron for different nk
echo "#    nk      Eform" > "E_vs_nk.dat"

for i in 6 8 10 12 14

do

sed -e "31s/.*/  nkf1          = $i/" \
    -e "32s/.*/  nkf2          = $i/" \
    -e "33s/.*/  nkf3          = $i/" \
    -e "34s/.*/  nqf1          = $i/" \
    -e "35s/.*/  nqf2          = $i/" \
    -e "36s/.*/  nqf3          = $i/" \
    "lif.epw2.in" > "lif.epw2.$i.in"

# run jobs
j=$(( 4*$i ))
ibrun -np $j $PATHQE/bin/epw.x -npool $j -input lif.epw2.$i.in > lif.epw2.$i.out

grep 'Formation Energy (eV):' "lif.epw2.$i.out" >> "E_vs_nk.dat"

sed -i "s/.Formation Energy (eV):/ $i/" "E_vs_nk.dat"

done


# echo finishing time
date
