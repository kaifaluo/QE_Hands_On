EPSILON-parallel Kernel
=======================

This kernel simulate the chi-summation in epsilon (static) running in parallel.

Short Description:
------------------
* The goal of this kernel is to simulate the matrix operations on a per MPI task level without running the actual global problem size using `nproc` MPI tasks. You can even choose to run this on 1 MPI tasks, but the MPI communication pattern will not be present.
* The kernel is simulating a large distributed matrix multiplication between the tall and skinny matrices: basically `M^{T} x M`.
* The total number of columns of the distributed matrices is given by `nmtx` parameter in input, 94,317 for the actual input
* The total number of row of the distributed matrices is given by `(Nvalence bands) * (Nbands total - (Nvalence bands))` parameters in input, 54,590,600 for the actual input
* The matrix is distributed locally as if the calculation is run using `nproc simulated` MPI tasks with ScaLAPACK 2D grid of size `Nprow x Npcol`, 9216 MPI tasks distributed as 96x96 for the actual input.
* `Number of repetition` gives how many iteration of the original algorithm should be performed, for the real run `Number of repetition` is equal to `nproc simulated`. If statistics or average are not important, you can set this value to `1`
* For each iteration there is a ZGEMM call plus some non-blocking point to point communication, for the the actual example the sizes are `N = 986 ; M = 986 ; K = 5924` with `K` inner dimension, `N, M, K` are given in output when running the calculation

Exercise:
--------- 

* Have a look to the Makefile, what compiler is used? Which BLAS library is used? There are references to ScaLAPACK,  why is this required?

* Type `make` to build the kernel `epsilon_kernel.ex`

* Have a look to the input structure/parameters `input_Si1000_12Ry`:
    *    1      ! Nspin x Nkpoints
    *    1996   ! Nvalence bands
    *    29346  ! Nbands total
    *    94617  ! nmtx (distributed matrix size)
    *    9216   ! nproc simulated
    *    96     ! Nprow in ScaLAPACK layout (Nprow * Npcol  = Nproc)
    *    96     ! Npcol in ScaLAPACK layout (Nprow * Npcol  = Nproc)
    *    25     ! Number of repetition eventually will be equal to Nproc simulated

*  To run on Frontera, (after creating and interactive session), use
  
  `export OMP_NUM_THREADS=1`
  `ibrun -n  8   ./epsilon_kernel.ex < input_Si1000_12Ry `
  
* What's the peformance of the ZGEMM operation? What's the formula tha gives you the total FLOPs from N,M,K parameters? 

* Repeat the calculation by `export OMP_NUM_THREADS=2` and `export OMP_NUM_THREADS=4`. What's changing? What is this variable controlling? 

* Have a look to the `timings_zgemm_tot.dat` file, is the workload well load balanced? 

* To simulate load imbalance Open the `epsilon_kernel.f90` search for `simulate_load_imbalance = .FALSE.` and replace FALSE with TRUE. Recompile by typing make and run rerun (`export OMP_NUM_THREADS=2`). Have a look to the `timings_zgemm_tot.dat` file, how does it compare with the previous case? What's the difference between ZGEMM and Cycle time?

* Advance: Rewrite the communication scheme to use `MPI_Reduce`.
