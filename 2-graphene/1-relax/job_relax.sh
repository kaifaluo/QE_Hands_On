#!/bin/bash
#SBATCH -J kfluo_relax_NbSe2_sl          #Job name
#SBATCH -p development                  # Queue (partition) name
#SBATCH -N 20                       # Total # of nodes 
#SBATCH -n 1024
#SBATCH -t 1:00:00                # Run time (hh:mm:ss)
#SBATCH -A DMR21002                # Project name 

module list
pwd
date

# Launch MPI code... 
export PATHQE=/work2/08220/kfluo/frontera/qe-7.0

ibrun $PATHQE/bin/pw.x -nk 1024 -in relax.in > relax.out

date

