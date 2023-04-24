# Silicon (2) - 2-bgw/3-kernel

In this directory we calculate the kernel of the Bethe-Salpeter equation (BSE)
using the Kernel code from BerkeleyGW. The kernel is calculated on a coarse
4x4x4 grid. This is the same grid on which the self energy Sigma was
calculated, but one could have used different grids.


## Instructions

1. Open the input file `kernel.inp`. Compare the tags present in the file
   against the documentation of `kernel.inp` in the manual.

2. Run the kernel calculation using `./01-run_kernel.run`. The calculation
   should take about a minute.

3. There are not many informative quantities that can be readily read from the
   output. For instance, the code prints the Frobenius norm of the head, wing
   and body components of the direct interaction matrix, as well as the
   exchange matrix. While these values are physically not useful, they should
   be constant for a given calculation (as long as you don't break
   degeneracies).
