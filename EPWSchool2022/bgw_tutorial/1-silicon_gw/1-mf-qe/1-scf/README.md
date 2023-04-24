# Silicon - MF/scf - QE

In this directory we perform a standard SCF calculation and obtain a charge
density which will be used to generate all the other WFNs with Quantum
ESPRESSO.

1. Start the calculation with `./01-calculate_scf.run`.

2. Take a look at `scf.in` for QE. What functional, cutoff, and k-grid are
   being used?

3. Look briefly at the `scf.out` file when the run finishes. Did the run
   succeed? Find the list of k-points in the `scf.out`.
