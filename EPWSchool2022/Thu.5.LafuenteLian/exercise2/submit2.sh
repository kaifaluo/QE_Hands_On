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
ibrun -np 56 $PATHQE/bin/epw.x -npool 56 -input lif.epw3.in > lif.epw3.out

# echo finishing time
date
