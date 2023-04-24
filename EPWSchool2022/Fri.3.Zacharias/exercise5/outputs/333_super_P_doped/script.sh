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
# ibrun -np 56 $PATHQE/bin/pw.x -nk 8 < si.relax_333.in > si.relax_333.out
# ibrun -np 56 $PATHQE/bin/pw.x -nk 8 < si.scf_333.in > si.scf_333.out
#ibrun -np 56 $PATHQE/bin/ph.x -nk 8 < si.ph_333.in > si.ph_333.out
#ibrun -np 1 $PATHQE/bin/q2r.x < q2r.in > q2r.out
#ibrun -np 56 $PATHQE/bin/ZG.x -nk 56 < ZG_ph_unfold.in > ZG_ph_unfold.out
 ibrun -np 56 $PATHQE/bin/pp_spctrlfn.x -nk 56 < pp_spctrlfn.in > pp_spctrlfn.out
                                                                                                      
exit
