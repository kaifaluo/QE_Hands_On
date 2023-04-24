# Hands-on Session: Silicon/BSE

- Original author: Felipe H. da Jornada


## Overview

In this session we will calculate the optical absorption spectrum of Silicon
within the GW-BSE formalism. We'll continue from where we left off in tutorial
1, where you calculated the quasiparticle band structure of silicon within the
GW approximation.


## Goals

The basic goals are the following:

1. Learn how to use the `kernel` and `absorption` codes.

2. Plot the optical absorption spectrum of silicon with and without e-h
   interactions.

The stretch goals are:

1. Use scissors corrections with the absorption code.

2. Compare results with RPA spectrum with local fields.


# Instructions

1. Go to the `1-mf/` directory, where we perform all the mean-field
   calculations. Follow the steps in the `README.md` file to generate the
   various wavefunctions.

2. Go to the `2-bgw/` directory, where we perform GW/GW-BSE calculations.
   Follow the instructions in the `README.md` file to perform the GW/GW-BSE
   calculations.
