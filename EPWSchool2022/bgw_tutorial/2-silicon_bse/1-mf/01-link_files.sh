#!/bin/bash -l

# This serial script links the WFN files from the MF to the BGW folder.

# First, link all CD files
echo "Linking pseudopotential and charge densities"
for directory in 3*-*/; do
  echo " Working on directory $directory"
  cd $directory
  mkdir -p Si.save
  ln -sf ../../1-scf/Si.save/charge-density.dat Si.save/
  ln -sf ../../1-scf/Si.save/data-file.xml Si.save/
  ln -sf ../../1-scf/Si.save/data-file-schema.xml Si.save/
  ln -sf ../1-scf/Si.UPF .
  cd ../
done
echo

echo "Linking WFNs to BGW directory"
cd ../2-bgw/

echo " Working on directory 3-kernel"
cd 3-kernel/
ln -sf ../../1-mf/2.1-wfn/WFN WFN_co
cd ../

echo " Working on directory 4-absorption"
cd 4-absorption/
ln -sf ../../1-mf/2.1-wfn/WFN WFN_co
ln -sf ../../1-mf/3.1-wfn_fi/WFN WFN_fi
ln -sf ../../1-mf/3.2-wfnq_fi/WFN WFNq_fi
cd ../

echo
echo "Done!"
