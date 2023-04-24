# Silicon (2) - 2-bgw/4-absorption/converge_kpts/wfn_fi

In this directory we perform a non-self-consistent (NSCF) mean-field calculation
to generate all of the Bloch states needed for the GW-BSE calculation.

Follow the following steps:

1. Run `./01-link_files.sh` to link in the files from previous mean-field runs.

2. Take a look at the input file (`kgrid.inp`) for `kgrid.x`. What changed
   compared to the previous fine grid we were using in the BSE calculations?

3. Run `./02-get_kgrid.sh` to generate the k-grid, and take a look at the
   output.

4. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file. Take a look ad the input file.

5. Run `./03-calculate_wfn.run` to calculate the wavefunctions using Quantum
   ESPRESSO. This should take about 1 minute. These wavefunctions will be
   written to files in Quantum ESPRESSO format, and then
   converted to BGW format using the utility `pw2bgw.x`.
