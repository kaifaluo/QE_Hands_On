# Hands-on Session: Silicon


## Overview

In this session we will calculate the quasiparticle band structure of silicon
using the LDA and GW approximations. You will perform the starting mean-field calculation
using Quantum ESPRESSO (QE).


## Goals

The basic goals are the following:

1. Understand the basic workflow of BerkeleyGW, and the relation between the
   k-grids, wavefunctions, and the Epsilon, Sigma, and Inteqp codes.

2. Run a basic GW calculation on silicon with the generalized plasmon pole
   (GPP) model.

3. Construct an interpolated bandstructure via scissors parameters and Inteqp.


The stretch goals are:

1. Compare your Sigma GW results with Hartree-Fock and/or static COHSEX.
   What inputs are no longer necessary? How do the results compare? 

2. Modify the example for GaAs and repeat each step of the calculation.

3. Adapt the calculation to use half-shifted k-grids.


## Instructions

1. Go to the mean-field 1-mf-qe to use Quantum ESPRESSO (QE),
   QE is recommend because it is a popular DFT code with a
   well-tested and mature wrapper for BerkeleyGW. BerkeleyGW supports 
   many other Mean-field code, a comprehensive list can be found here 
   <http://manual.berkeleygw.org/3.0/meanfield/>

2. After you perform all steps in the mean-field folder, go to the
   2-bgw folder for the BerkeleyGW calculations  and follow the
   instructions in the `README.md` file.
