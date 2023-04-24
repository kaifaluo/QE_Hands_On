#!/bin/bash -l

# This serial script runs kgrid.x to generate a file containing all
# the irreducible k-points (kgrid.out) and the relevant symmetry 
# operations (kgrid.log).

# module load berkeleygw-tutorial
kgrid="kgrid.x"

ibrun -np 1     $kgrid ./kgrid.inp ./kgrid.out ./kgrid.log
