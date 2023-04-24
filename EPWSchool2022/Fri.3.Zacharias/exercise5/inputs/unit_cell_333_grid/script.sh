#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=56
#SBATCH --job-name=job2
#SBATCH --time=01:30:00
# Queue (Partition):
#SBATCH --partition=development
#SBATCH --account=EPSchool2022


cd $PWD

PATHQE=~/codes/q-e_latest_for_merge/
 ibrun -np 4 $PATHQE/bin/pw.x -nk 4 < si.scf.in > si.scf.out
ibrun -np 4 $PATHQE/bin/ph.x -nk 4 < si.ph.in > si.ph.out
ibrun -np 1 $PATHQE/bin/q2r.x < q2r.in > q2r.out
ibrun -np 1 $PATHQE/bin/matdyn.x < matdyn.in > matdyn.out
                                                                                                      
exit
