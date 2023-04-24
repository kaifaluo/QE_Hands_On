# Silicon - Mean Field - QE

In this directory, we will perform all the mean-field calculations for
BerkeleyGW using Quantum ESPRESSO (QE).


## Instructions

1. First, run the script `./01-link_files.sh`. It will create links for the
   charge density, pseudopotentials, exchange-correlation matrix elements, and
   WFN files.

2. Go to each directory in the numeric order they appear, but skipping
   `2.1.1-wfn-parabands` for now (this folder teaches how to use Quantum
   ESPRESSO together with ParaBands to generate a large number of unoccupied
   states, and it is a stretch goal). Follow the instructions in each file
   `README.md`. Note that the gap between `2.2-wfnq` and `4-bandstructure` is intentional,
   additional wavefunction calculations (labelled with `3.`) will be run in the BSE exercise.


## Strech goal (For the Hackathon)

After you finish all mean-field and GW calculations, go to the folder
`2.1.1-wfn-parabands` and follow the instructions.
