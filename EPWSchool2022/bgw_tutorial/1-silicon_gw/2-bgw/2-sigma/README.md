# Silicon - BGW/Sigma

In this directory we calculate the GW quasiparticle energies for silicon using
the Sigma code from BerkeleyGW.

Follow these steps:

1. Run the sigma calculation using `./01-run_sigma.run`.

2. Study the input file `sigma.inp` and compare to the input file description
   in the manual <http://manual.berkeleygw.org/3.0/sigma-keywords/>.

3. What files are linked into this directory? How are they used?

4. Which `kgrid.x` run should you use to populate the list of k-points in
   `sigma.inp`?  What are these k-points used for? What happens if you add or
   remove some?

5. Use `degeneracy_check.x` to determine what numbers of bands are acceptable
   with respect to degeneracy from `WFN_inner` (run `degeneracy_check.x WFN_inner`). 
   Is the number listed in `sigma.inp` an acceptable number? How many bands are available in
   `WFN_inner`? How do the degeneracy numbers compare to those needed for
   Epsilon? Why?

6. When the job is finished, take a look at the output file `sigma_hp.log`.
   Compare the k-points and bands requested to what is written in the results.
   What does each column mean? Which one is the best estimate of the
   quasiparticle energies? What are the values of the quasiparticle
   renormalization factors?

7. Look at `sigma.out` for any warnings (marked `WARNING`) that may have
   occurred.  Try to understand their meaning and whether there is any cause
   for concern.

8. Descend into the `bandstructure` directory to calculate an interpolated
   quasiparticle bandstructure with the inteqp code.
