# Silicon (2) - 1-mf/2.1-wfn

Although not required, it is customary to use the same `WFN` file that was used
in Sigma also in Kernel. The reason is simple: we usually interpolate both the
matrix elements from the Bethe-Salpeter equation (BSE), which is calculated in
Kernel, and the quasiparticle energies, calculated in Sigma. But if the
quasiparticle energies and the kernel matrix elements are calculated on the
same k-grid, we might as well use the same `WFN` file for Sigma and Kernel.

Run `./01-reuse_files.sh` to links the `WFN` file from the first silicon
example. We won't need the exchange-correlation matrix elements (`vxc.dat`) nor
the charge density (`RHO`), because these files are not required by Kernel.
