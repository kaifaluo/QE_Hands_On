SIGMA-serial Kernel
===================

This kernel simulate the `mtxel_cor` module in sigma, in particular the generalized plasmon pole model (GPP). The miniapp runs in serial but simulate the core computation for each MPI rank in a parallel run.

* Type make to build the miniapp `gppKerFort.ex`.

* To run use: 

  `export OMP_NUM_THREADS=1`
  `ibrun -np 1 ./gppKerFort.ex 6000 500 25000 1024`

   ```
   Where the input parameter are: 
    *  6000   ! Number of bands to sum over
    *   500   ! Number of valence bands
    * 25000   ! Number of G-vectors up to the screened coulomb cutoff
    *  1024   ! Number of MPI tasks simulated
   ```

Running with these parameters the output results should match:
```
 Answer-ch[1]: (-34615384.6153883,173076923.076878)
 Answer-ch[2]: (-17999999.9999995,125999999.999998)
 Answer-ch[3]: (-10975609.7560956,98780487.8049063)
 
 Answer-sx[1]: (4384615.38461715,-3923076.92307611)
 Answer-sx[2]: (2414634.14634122,-2268292.68292556)
 Answer-sx[3]: (1529388.24470248,-1469412.23510591)
 
 Answer-Stat: (-450000000.000000,-450000000.000000)
```

The total time (`Runtime:`) is the combination of the time spent in the computation of the self energy (`Runtime SE:`) and the static reminder (Runtime Stat:), a method to accellerate the convergence wrt the number of bands.

* The goal of this exercise is to implement multicore parallelize for the miniapp using OpenMP. You can test the parallel efficiency of your implementation by running `gppKerFort.ex` by exporting an increasing number of `OMP_NUM_THREADS`:

  `export OMP_NUM_THREADS=XXX`
  `ibrun -np 1 ./gppKerFort.ex 6000 500 25000 1024`
   With XXX=1, 2, 4, 8 and 16

* Usefull OpenMP commands:
   * Create a parallel do over threads:
     `!$OMP PARALLEL DO ` 
     `!$OMP END PARALLEL DO `
   * Variable attirbute:
     `!$OMP private()`
     `!$OMP shared()`
   * Perform the reduction of the variable `var` at the end of the parallel region:
     `!$OMP reduction(+: var)

* Advanced: Implement GPU support for the kernel by using OpenMP-target and OpenACC programming models. Measure speedup compared to CPU implementation. 
