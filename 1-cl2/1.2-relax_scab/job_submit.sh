#!/bin/bash
#SBATCH -J kfluo_test_carbonchain  #Job name
#SBATCH -p small                   # Queue (partition) name
#SBATCH -N 1                       # Total # of nodes 
#SBATCH --ntasks-per-node 56
#SBATCH -t 01:00:00                # Run time (hh:mm:ss)
#SBATCH --mail-type=all
#SBATCH -A DMR21002                # Project name 

module list
pwd
date

# Launch MPI code... 
export PATHQE=/work2/08220/kfluo/frontera/qe-7.0

for filename in ./scfs/*
do
	ibrun $PATHQE/bin/pw.x -nk 56 -in $filename > $filename.out &
	date
done

