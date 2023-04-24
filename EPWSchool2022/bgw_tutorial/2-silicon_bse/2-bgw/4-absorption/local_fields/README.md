# Silicon (2) - 2-bgw/4-absorption/local_fields

When you run a regular BSE calculation with Absorption, local fields are
included in the file `absorption_eh.dat` but not in `absorption_noeh.dat`. So,
we are actually comparing the following two theories: GW-RPA without local
fields, and GW-BSE with local fields.

In this example, you will learn how to generate an optical absorption spectrum
within the GW-RPA approximation including local fields.


## Instructions

1. Run `./01-link_files.sh` to link the `WFN`, `bsemat.h5` and `epsmat.h5`
   files.

2. Edit `absorption.inp` and fill in the missing parameters.

3. Compare the `absorption.inp` file with your previous file. What's the
   difference?

4. Run `./02-run_absorption.run` to launch the absorption calculation.

5. Compare `absorption_eh.dat` against `absorption_noeh.dat` and your previous
   `absorption_eh.dat`. What is the effect of local fields alone on the optical
   absorption spectrum of silicon? Is the RPA theory with local fields enough
   to explain experiments? What is missing?

6. Compare the `absorption_noeh.dat` file with the previous version. What
   changed?
