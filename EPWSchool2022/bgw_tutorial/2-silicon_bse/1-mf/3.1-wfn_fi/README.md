# Silicon (2) - 1-mf/3.1-wfn_fi

In this directory we perform a non-self-consistent (NSCF) mean-field calculation
to generate all of the Bloch states needed for the GW-BSE calculation. The 
Absorption code uses two WFN files: one which is used just for the conduction
states, and one for the valence states. Just like in the Epsilon code, we need
the two k-grids to have a finite shift to properly handle `q->0` transitions.

Follow the following steps:

1. Take a look at the input file (`kgrid.inp`) for `kgrid.x`. What is the
   k-grid that we are using? What is the shift? Why are we using this shift?

2. Run `./01-get_kgrid.sh` to generate the k-grid, and take a look at the
   output.

3. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file. Take a look ad the input file.

4. Run `./02-calculate_wfn.run` to calculate the wavefunctions using Quantum
   ESPRESSO. This should take about 1 minute. These wavefunctions will be
   written to files in Quantum ESPRESSO format, so they will need to be
   converted to BGW format in the next step using the utility `pw2bgw.x`.

6. Run `./03-convert_wfn.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.
