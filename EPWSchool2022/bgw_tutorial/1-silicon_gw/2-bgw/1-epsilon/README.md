# Silicon - BGW/Epsilon

In this directory we calculate the RPA dielectric matrix of silicon using the
Epsilon code from BerkeleyGW.

Follow these steps:

1. Run the epsilon calculation using  `./01-run_epsilon.run`.

2. Study the input file `epsilon.inp` and compare to the input file description
   in the manual <http://manual.berkeleygw.org/3.0/epsilon-keywords/>.

3. What files have been linked into this directory? How are they used?

4. The dielectric function $\epsilon(q)$ must be calculated for all q-points
   such that $q = k - k'$. For $|q| \ne 0$, all $k$-points are coming from `WFN`.
   In this case, which are the possible $q$-points for $\epsilon(q)$? Use
   `kgrid.x` (and your own editing) to generate the list of $q$-points for
   `epsilon.inp`.  Why do we need to specify $q$-points? What $q$-shift are we
   using?

5. Use `degeneracy_check.x` to determine what numbers of bands are acceptable
   with respect to degeneracy from `WFN` (run `degeneracy_check.x WFN`). 
   Does `WFNq` matter?  Is the number listed in `epsilon.inp` an acceptable number? 
   What happens if you change it to another value? How many bands are available in `WFN` and `WFNq`?

6. When the job is finished, take a look at `epsilon.out`.  What are the values
   of $1/\epsilon^{-1}_{0,0}(0)$ and $\epsilon_{0,0}(0)$?  Why is there a
   difference?  (Hint: find these values by searching for `Head`.) Make a plot
   of $1/\epsilon^{-1}_{0,0}(q)$ and $\epsilon_{0,0}(q)$ against $|q|$. (Hint:
   look for the section with `Q0 and |Q0|`.) Is it following the expected
   behavior as $q \rightarrow 0$? What do these values mean physically? Which is "the
   dielectric constant" as you would measure with a capacitor?

7. Take note of the two files that were produced: `epsmat.h5` and `eps0mat.h5`.
   What do they mean? Which $q$-points should be in each one?

8. Look at `epsilon.out` for any warnings (marked `WARNING`) that may have
   occurred.  Try to understand their meaning and whether there is any cause
   for concern.
