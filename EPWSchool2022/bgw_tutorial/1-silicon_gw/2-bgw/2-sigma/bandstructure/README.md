# Silicon - BGW/Inteqp

In this directory we calculate an interpolated quasiparticle bandstructure for
silicon using the Inteqp code from BerkeleyGW.

Follow these steps:

1. Run the inteqp calculation using `./01-run_inteqp.run`.

2. Study the input file `inteqp.inp` and compare to the input file description of absorption.inp
   in the manual <http://manual.berkeleygw.org/3.0/inteqp-keywords/>.
   Why do we need to interpolate rather than just directly run Sigma on these k-points? How is
   the number of coarse points listed determined? Why do we want to use
   symmetries on the coarse grid but not the fine one?

3. What files are linked into this directory? How are they used?

4. Use `degeneracy_check.x` to determine what numbers of conduction and valence
   bands are acceptable with respect to degeneracy from `WFN_co` and `WFN_fi`
   (run `degeneracy_check.x WFN_co` and `degeneracy_check.x WFN_fi`).
   Are the numbers listed in `inteqp.inp` acceptable? How many bands are
   available in `WFN_co` and `WFN_fi`? How do the degeneracy numbers compare to
   those needed for Epsilon or Sigma? Why?

5. When the job is finished, take a brief look at `inteqp.out`. What warning do
   you see at the end? Look at `dcmat_norm.dat` and `dvmat_norm.dat` to see
   which values are being flagged as less accurate. How could you improve the
   accuracy of the interpolation for these energy levels?

6. Plot the resulting bandstructure.

   Run `python3 ./02-plot_bandstructure.py`. Don't worry if you get a message
   about building a font cache as it runs. This will produce `Si_bands.pdf`.
   View with `display Si_bands.pdf` or with the JupyterLab file browser.

7. Using `Si_bands.pdf` and `bandstructure.dat`, find the energy and location
   of the the direct gap and indirect gap, for LDA and GW. What is the valence
   band- width for LDA and GW? How do the band curvatures (effective masses)
   and band topology compare between LDA and GW?

8. Use `python3 ./qp_shifts.py ../sigma_hp.log` to produce `cond` and `val` files
   containing a list of MF eigenvalues (column 1) and quasiparticle corrections
   (`E_qp - E_MF`, column 2) for conduction and valence bands, respectively, in a
   format suitable for plotting. Make a graph of quasiparticle corrections as a
   function of initial energy. Over what range of energies around the gap would
   a linear fit be appropriate? Why is the relation different for conduction
   and valence? Why is it non-linear farther away?

9. Perform a linear fit on the linear regime, separately for `cond` and `val`.
   For example with gnuplot, to fit between energies `E_1` and `E_2`, you could first type gnuplot,
   then you would do:

   ```
   gnuplot > f(x)=a*x+b;a=1;b=1      # a,b initial guesses, doesn't matter 
   gnuplot > fit [E_1:E_2] f(x) 'cond' via a,b
   [output giving you the fit parameters] 
   gnuplot > plot f(x), 'cond'       # let you see the fitted line with data
   ```

   How good is the fit? How well does it describe the QP corrections farther from
   the gap? You will later use these fits in the calculation of the optical
   absorption, as a stretch goal in a later example.

10. Do a fit also on the whole range of values (just remove the `[E_1:E_2]`
    part). How good are the fits? Apply these linear relations to
    `bandstructure.dat` and compare the results to the more rigorous (but
    time-consuming) calculation from inteqp. You can also add the inteqp
    `bandstructure.dat` values to `cond` and `val` and see how the points there
    compare to the ones from Sigma on the regular grid.
