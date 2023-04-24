Eigensolver's Kernels
=====================

* This collections of miniapps build up an Hermitian matrix and diagonalize it to test the performance of various libraries. You can also read the matrix to diagonalize from file (binary format).

* In this exercise we will use Scalapack (pzheevd) and ELPA eigensolvers. 

* Have a look to the `arch.mk` file, which scalapack implementation are we using? Which ELPA implementation are we using? 

* To build the miniapps type `make scalapack elpa`. What's the name of the generated executables?

* To run on Frontera (after creating and interactive session), use for example:

  `export OMP_NUM_THREADS=2`
  `ibrun -np  4  ./pzheevd.ex   4000  2  2  64  ` for scalapack
  `ibrun -np  4  ./elpa.ex      4000  2  2  64  ` for ELPA
  
  Where
    * 4000 is the number of row/col of the distributed matrix
    * 2 is the number of row processes of the 2D block cyclic data layout 
    * 2 is the number of column processes of the 2D block cyclic data layout  
    * 64 is the block size of the 2D block cyclic data layout 
  
  Note that the number of row processes times the number of column processes  has to be equal to the total number of MPI tasks (`-np` argument).

Scaling of Computational Cost with System Size:
-----------------------------------------------

* For both scalapack and ELPA, run a series of diagonalization for matrices of increasing size between 2000 to 5000 using (6-8 points) a single MPI task and two OMP threads 

   `export OMP_NUM_THREADS=2`
   `ibrun -np  1  ./pzheevd.ex   XXX  1  1  64  ` 
   with XXX between 2000 and 5000

* For both scalapack and ELPA, plot the time vs matrix size (time is in seconds, look for `PZHEEVD time:` and `ELPA time:`). Which function would you use to fit the data? 

* From the fitted data exctract the increase of computational cost (time to solution) as a function of the matrix size in `O` notation.

* Estimate how long it would take to diagonalize a matrix of size 50k using a single MPI task (two OMP threads) using Scalapack and ELPA.

Parallel Scaling:
-----------------

* For both scalapack and ELPA and a matrix of fixed size 5000, run a series of diagonalization increasing the number of MPI tasks for each calculation (two OMP threads per task):

   `export OMP_NUM_THREADS=2`
   `ibrun -np  X  ./pzheevd.ex   5000  Y  Z  64  
   X = 1,2,4,6,8 and 12 ; Y*Z=X

* Plot the parallel strong scaling for the two libraries. What should be the ideal time to solution when running with 4 and 12 MPI tasks? What's the parallel efficiency for the 4 and 12 MPI tasks run? 

* Advance: Using the results from the previous exercises perform a set of calculations to measure the weak scaling for the two libraries. 


