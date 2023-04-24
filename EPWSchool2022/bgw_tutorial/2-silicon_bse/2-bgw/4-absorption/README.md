# Silicon (2) - 2-bgw/4-absorption

In this directory we interpolate the kernel of the Bethe-Salpeter equation
(BSE) that was calculated on a 4x4x4 grid and solve the BSE to obtain the
optical absorption spectrum.


## Part 1: Basic Usage

The recommended workflow is to interpolate the quasiparticle corrections
calculated from Sigma onto a finer grid. This is done automatically by
the code without any input from the user. We will follow that strategy right now.

Follow the following steps:

1. Run `./01-link_eqp.sh` to link the file `eqp.dat`, containing the
   quasiparticle energies calculated from Sigma, to `eqp_co.dat`. This file,
   which was calculated on a 4x4x4 grid, will be interpolated by the 
   Absorption code into the files `eqp.dat` and `eqp_q.dat`, both defined on a
   8x8x8 grid.

2. Take a look at the files in the directories and all the symbolic
   links. Where are the files coming from? Which k-grids are being used?

3. What is the polarization of the incoming photon? Hint: take a look
   at the expression for the absorption spectrum and use the
   `wfn_rho_vxc_info.x` utility on `WFN_fi` and `WFNq_fi` files. For example,
   you could run: `wfn_rho_vxc_info.x WFN_fi > wfn.log` and
   `wfn_rho_vxc_info.x WFNq_fi > wfnq.log`. If you are used to working
   with `vim`, run `vimdiff wfn.log wfnq.log`, otherwise run
   `diff wfn.log wfnq.log | less -S`. Pay attention to the part about the
   k-grid and the k-points. The goal here is also to get you used to
   the `wfn_rho_vxc_info.x` utility, which is very helpful to detect
   inconsistencies in mean-field calculation.

4. Open the input file `absorption.inp`, and fill up the missing values based
   on the input of your kernel calculation. In general, should we include
   more bands from the coarse WFN or fine WFNs? Why?

5. Run `./02-run_absorption.run` to perform the Absorption calculation.
   The calculation should take about a minute. Take note of the output files
   that were produced.

6. Plot the optical absorption spectra. The relevant files are
   `absorption_noeh.dat`, which contains the GW-RPA optical absorption 
   spectrum without local fields, and `absorption_eh.dat`, which contains 
   the GW-BSE absorption spectrum (with electron-hole interactions and local-
   field effects). What are the main features you see in the graphs?


## Part 2: Convergence - bands

Go to the directory `converge_bands/` and follow the instructions.


## Part 3: Convergence - k-points

Go to the directory `converge_kpts/` and follow the instructions.


## Part 4: Scissors Operators (if time allows)

Go to the directory `scissors/` and follow the instructions.


## Part 5: Local Fields (if time allows)

Go to the directory `local_fields/` and follow the instructions.
