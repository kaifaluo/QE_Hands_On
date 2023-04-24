#!/bin/bash -l

# module load berkeleygw-tutorial
kgrid="kgrid.x"

ibrun -np 1     $kgrid ./kgrid.inp ./kgrid.out ./kgrid.log
