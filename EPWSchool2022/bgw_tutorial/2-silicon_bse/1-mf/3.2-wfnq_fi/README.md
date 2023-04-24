# Silicon (2) - 1-mf/3.2-wfnq_fi

In this directory we the second part of the non-self-consistent (NSCF)
mean-field calculation, where we generate the q-shifted wavefunction file for
the `absorption` calculation.

Follow the following steps:

1. Take a look at the input file (`kgrid.inp`) for `kgrid.x`, and run
   `./01-get_kgrid.sh`. What changed from the previous k-grid?

2. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file. Take a look ad the input file.

3. Run `./02-calculate_wfnq.run` to calculate the wavefunctions using Quantum
   ESPRESSO. This should take about 1 minute. These wavefunctions will be
   written to files in Quantum ESPRESSO format, so they will need to be
   converted to BGW format in the next step using the utility `pw2bgw.x`.

4. Run `./03-convert_wfnq.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.

