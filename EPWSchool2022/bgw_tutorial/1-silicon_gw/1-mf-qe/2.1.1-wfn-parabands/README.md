# Silicon - MF WFN - QE + ParaBands

In this directory we perform a non-self-consistent (NSCF) mean-field
calculation to generate all of the Bloch states needed for the subsequent GW
calculations. We use The resulting wavefunction file will then be read as `WFN` by
the Epsilon code, and `WFN_inner` by the Sigma code.

This directory is analogous to the `../2.1-wfn` directory that you ran
previously, but we use here a combination of Quantum ESPRESSO and, ParaBands, a
mini-DFT code shipped with BerkeleyGW, to speedup the calculation of many empty
states. We recommend you only run this example after you finish all basic DFT
and GW calculations with Quantum ESPRESSO and BerkeleyGW!


Follow the following steps:

1. Note that we will still run `kgrid.x` and Quantum ESPRESSO just like in the
   calculation with QE in `../2.1-wfn`. What changed in the input files
   `kgrid.inp`, `bands.in` and/or `pw2bgw.inp`?

2. Run `./01-get_kgrid.sh` to generate the k-grid. Take a look at the output
   output `kgrid.out` and the log `kgrid.log`.

3. Copy the k-points in the reduced BZ from `kgrid.out` and put them in the
   Quantum ESPRESSO input file (`bands.in`) in the specified location at the
   end of the file.

4. Run `./02-calculate_wfn.run` to calculate the wavefunctions using Quantum
   ESPRESSO. This should take about 1 minute. These wavefunctions will be
   written to files in Quantum ESPRESSO format, so they will need to be
   converted to BGW format in the next step using the utility `pw2bgw.x`.
  - check the input file `bands.in`. How many bands are we calculating? Why?

5. Take a look at the input file (`pw2bgw.in`) for `pw2bgw.x`, our utility that
   converts wavefunctions in Quantum ESPRESSO format to BGW format. Compare
   this input file with the documentation available in the code. 

  - Should you be writing a real or complex wavefunction? Why? What's the name
    of the wavefunction file that is output by `pw2bgw.x`?

  - Note that we are now writing the exchange-correlation file in G-space
    $V_{xc}$ as a matrix into file `VXC` instead of compute the matrix elements
    $\langle n | V_{xc} | m \rangle$ in `vxc.dat`. We do this because we will
    eventually run ParaBands and obtain another set of Kohn-Sham states
    $\{n\}$, typically containing many more bands. In addition, ParaBands can
    typically yield states much more converged than QE, so the two sets of
    orbitals may differ. So, we ask BerkeleyGW to compute the matrix elements
    $\langle n | V_{xc} | m \rangle$ instead of askin QE to produce these
    matrix elements.

  - In addition to `VXC`, `pw2bgw.x` will also produce two new files: `VSC` and
    `VKB`. These contain the local Kohn-Sham potential and the non-local
    projectors associated with the pseudopotentials for the give k-points.

6. Run `./03-convert_wfn.run` to convert the wavefunction file from Quantum
   ESPRESSO to the BerkeleyGW format.

7. We will now use files `WFN_in`, `VSC`, and `VKB` to perform another
   mean-field calculation with ParaBands, where we explicitly diagonalize the
   dense DFT Hamiltonian with ScaLAPACK. In fact the calculation that we just
   performed with QE was only needed to export the local potential and the
   projectors, so we can always perform a quick calculation with QE including
   only the occupied bands plus 1, and with a low convergence criterium. Take a
   look at the input file `parabands.inp` and compare with the documentation in
   the [ParaBands manual](http://manual.berkeleygw.org/3.0/parabands-overview/).
   - How many bands will we be generating?
   - What is the rough size of the DFT Hamiltonian that ParaBands will
     diagonalize?
   - Do you expect this calculation to run quickly?

8. Run ParaBands with `./04-run-parabands.sh`. Compare the output
   `parabands.out` with the answers that you gave previously.

9. For performance reason, ParaBands writes the output WFN file directly in a
   parallel HDF5 format. However, in this tutoral we won't use HDF5 format, so we
   need to convert that back to the binary format. Do that by running
   `./05-convert-to-binary.sh`.

10. Inspect the generated `WFN` file with the `wfn_rho_vxc_info.x` utility.

11. Finally, modify your Epsilon and Sigma calculation under `../../2-bgw/`
    accordingly to use the `WFN` file computed here and compare the final
    bandstructure.
