# Silicon - MF/Epsilon (WFNq) - QE

In this directory we perform a non-self-consistent (NSCF) mean-field
calculation to generate all of the Bloch states needed for the subsequent GW
calculations. The resulting wavefunction file will then be read as `WFNq` by
the Epsilon code.

Follow the following steps:

1. Take a look at the input file `kgrid.inp` for `kgrid.x`. Note the small
   q-shift. 

2. Run `./01-get_kgrid.sh` to generate the k-grid. Take a look at the output
   output `kgrid.out` and the more verbose log `kgrid.log`.
   - What k-grid was generated?
   - How many k-points are there in the full and symmetry-folded Brillouin
     zone?
   - Try to match up some points between this `kgrid.out` and that of
     `2.1-wfn`: each point in `WFNq` corresponds (with perhaps applying a
     symmetry) to one in `WFN`, plus the extra shift.

3. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file. Take a look ad the input file.

   - Why do we need fewer bands in these q-shifted wavefunctions?

4. Run `./02-calculate_wfn.run` to calculate the wavefunctions using Quantum
   ESPRESSO. This should take about 1 minute. These wavefunctions will be
   written to files in Quantum ESPRESSO format, so they will need to be
   converted to BGW format in the next step using the utility `pw2bgw.x`.

5. Take a look at the input file (`pw2bgw.in`) for `pw2bgw.x`, our utility that
   converts wavefunctions in Quantum ESPRESSO format to BGW format. Where is
   the q-shift indicated in the input file?

6. Run `./03-convert_wfn.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.

7. Take a look at the output file. Can you find the list of k-points?  Use
   `wfn_rho_vxc_info.x` to inspect the k-points in the `WFN` file (run the command `wfn_rho_vxc_info.x WFN`).  
   What is listed for the k-grid, shifts, and k-weights in the file? Are they
   meaningful here?
