# Silicon (2) - 2-bgw/4-absorption/scissors

Sometimes, the GW corrections to the mean-field eigenvalues are not very
dependent on the k-point and can be approximated by a simpler linear
correction, called a scissor operator. When this approximation is valid, it
allows the user to save time and calculate the self-energy on a grid much
coarser than that on which the kernel of the BSE is calculated. However, you
should bear in mind that finding the parameters for the scissors operators is
more laborious than than directly interpolating the quasiparticle corrections,
and also washes out the k-dependence of the GW corrections to the mean-field
band structure.


## Instructions

1. Run `./01-link_files.sh` to link the `WFN`, `bsemat.h5` and `epsmat.h5`
   files.

2. In case you did do it, go back to the first tutorial and extract the
   scissors parameters for silicon according to the instructions in the
   `README.md` file (it's in the `1-silicon_gw/2-bgw/2-sigma/bandstructure/` 
   directory). Up to which energy do you expect the linear approximation to be valid?

3. You should have fitted the GW corrections to the DFT eigenvalues as a
   function of the form: `$f(x) = a*x + b$`, where f(x) is the GW correction to
   the DFT eigenvalues, and x is the DFT eigenvalue. Now, cast the parameters
   $a$ and $b$ that you just fit into a form of scissors correction: `$e_cor =
   e_in + es + edel * (e_in - e0)$` What's the meaning of those 6 variables? How
   do you write them in terms of $a$ and $b$?

4. Edit `absorption.inp` and set the parameters `evs`, `evdel`, `ecs` and
   `ecdel` according to the scissors fit you just performed. Note that there is
   one set of parameters for valence and one for conduction bands.

5. Run `./02-run_absorption.run` to launch the absorption calculation.

6. Compare `absorption_eh.dat` with your previous file. Do you think the
   scissors operators were a good approximation for the absorption calculation?
