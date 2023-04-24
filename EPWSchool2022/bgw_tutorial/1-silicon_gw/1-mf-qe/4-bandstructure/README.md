# Silicon - MF/Bandstructure - QE

In this directory we perform a non-self-consistent (NSCF) mean-field
calculation to generate all of the Bloch states needed for the subsequent GW
calculations.  The resulting wavefunction file will then be read as `WFN_fi`
by the Inteqp code.

Follow these steps:

1. Run `./01-calculate_wfn.run` to calculate the wavefunctions using QE.

2. Look at the k-path specification in `bands.in` and the k-points generated in
   `bands.out` Identify what paths are being taken with respect to a diagram
   such as <http://www.iue.tuwien.ac.at/phd/dhar/node18.html>. Why don't we run
   `kgrid.x` for this? Should the points be reduced by symmetry?  How many
   bands are we using?

3. Run `./03-convert_wfn.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.

4. Take a look at the output file. Can you find the list of k-points?  Use
   `wfn_rho_vxc_info.x` to inspect the k-points in the `WFN` file (run `wfn_rho_vxc_info.x WFN`). 
   What is listed for the k-grid, shifts, and k-weights in the file? Are they
   meaningful here?
