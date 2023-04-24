# Silicon - MF WFN - QE

In this directory we perform a non-self-consistent (NSCF) mean-field
calculation to generate all of the Bloch states needed for the subsequent GW
calculations.  The resulting wavefunction file will then be read as `WFN` by
the Epsilon code, and `WFN_inner` by the Sigma code.

Follow the following steps:

1. Take a look at the input file (`kgrid.inp`) for `kgrid.x`, the executable
   that generates our k-grids for NSCF calculations. Compare with the
   documentation of `kgrid.x`. Note the line specifying the FFT grid. We take
   that from the SCF calculation, reported next to `FFT dimensions`.

2. Run `./01-get_kgrid.sh` to generate the k-grid. Take a look at the output
   output `kgrid.out` and the more verbose log `kgrid.log`.
   - What is the space group?
   - What are the symmetry elements of the crystal?
   - What k-grid was generated?
   - How many k-points are there in the full and symmetry-folded Brillouin zone?
   - See what symmetry operation was used to relate two points in the full BZ and
     reduce them to only one in the final result.

3. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file. Do not repeat the line starting with `K_POINTS crystal`.

   - How many bands are we generating?

4. Run `./02-calculate_wfn.run` to calculate the wavefunctions using Quantum
   ESPRESSO. These wavefunctions will be
   written to files in Quantum ESPRESSO format, so they will need to be
   converted to BGW format in the next step using the utility `pw2bgw.x`.

   - Check the input file `bands.in`. How many bands are we calculating?

5. Take a look at the input file (`pw2bgw.in`) for `pw2bgw.x`, our utility that
   converts wavefunctions in Quantum ESPRESSO format to BGW format. Compare
   this input file with the documentation available in the code. 

   - Should you be writing a real or complex wavefunction? Why? What's the name
     of the wavefunction file that is output by `pw2bgw.x`?
   - This will also output a `vxc.dat` file containing the DFT approximation to
     the exchange correlation. This file will be used by Sigma. Do you know why
     this file is necessary?
   - `pw2bgw.x` will also output `RHO`, the charge density, which is required to
     run Sigma.

6. Run `./03-convert_wfn.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.

7. Take a look at the output file. Can you find the list of k-points?  Use
   `wfn_rho_vxc_info.x` to inspect the k-points in the `WFN` file (run the command `wfn_rho_vxc_info.x WFN`)
   What is listed for the k-grid, shifts, and k-weights in the file? Are they
   meaningful here?
