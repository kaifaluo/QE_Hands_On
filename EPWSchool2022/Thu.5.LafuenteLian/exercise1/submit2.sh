#!/bin/bash
#SBATCH -J myjob              # Job name
#SBATCH -p small              # Queue (partition) name
#SBATCH -N 1                  # Total # of nodes
#SBATCH --ntasks-per-node 24
#SBATCH -t 01:00:00           # Run time (hh:mm:ss)
#SBATCH -A EPSchool2022
#SBATCH --reservation=EPSchoolDay4


# echo loaded modules, current directory, and starting time
module list
pwd
date

# export the path which contains executable file
export PATHQE=/work2/06868/giustino/EP-SCHOOL/q-e-epw-2022-polaron-master/

# Launch MPI code...
# Total # of parallel tasks
MPIOPT="-np "$SLURM_NTASKS
# kpoint parallel groups
KPTPRL="-npool 8"

# run jobs
# nscf calculation
ibrun ${MPIOPT} $PATHQE/bin/pw.x ${KPTPRL} -input lif.nscf.in > lif.nscf.out
# epw calculation
ibrun ${MPIOPT} $PATHQE/bin/epw.x -npool 24 -input lif.epw1.in > lif.epw1.out

# echo finishing time
date
