#!/bin/bash -l

# This serial script runs kgrid.x to generate a file containing all
# the irreducible k-points (kgrid.out) and the relevant symmetry 
# operations (kgrid.log).

# module load berkeleygw-tutorial

ibrun -np 16     parabands.real.x &> parabands.out
