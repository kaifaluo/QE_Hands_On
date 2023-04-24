#!/bin/bash
#SBATCH -J myjob              # Job name
#SBATCH -p small              # Queue (partition) name
#SBATCH -N 1                  # Total # of nodes
#SBATCH --ntasks-per-node 48
#SBATCH -t 00:30:00           # Run time (hh:mm:ss)
#SBATCH -A EPSchool2022
#SBATCH --reservation=EPSchoolDay4


# echo loaded modules, current directory, and starting time
module list
pwd
date

# export the path which contains executable file
export PATHQE=/work2/06868/giustino/EP-SCHOOL/q-e-epw-2022-polaron-master/

# Launch MPI code...

echo "#    nk      Eform" > "E_vs_nk.dat"

for i in 6 8 10 12 

do

sed -e "30s/.*/  nkf1          = $i/" \
    -e "31s/.*/  nkf2          = $i/" \
    -e "32s/.*/  nkf3          = $i/" \
    -e "33s/.*/  nqf1          = $i/" \
    -e "34s/.*/  nqf2          = $i/" \
    -e "35s/.*/  nqf3          = $i/" \
    "lif.epw4.in" > "lif.epw4.$i.in"

# run jobs
j=$(( 4*$i ))
ibrun -np $j $PATHQE/bin/epw.x -npool $j -input lif.epw4.$i.in > lif.epw4.$i.out

grep 'Formation Energy (eV):' "lif.epw4.$i.out" >> "E_vs_nk.dat"

sed -i "s/.Formation Energy (eV):/ $i/" "E_vs_nk.dat"

done


# echo finishing time
date
