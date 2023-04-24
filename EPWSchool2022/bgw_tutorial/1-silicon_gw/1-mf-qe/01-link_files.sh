#!/bin/bash -l

# This serial script links the WFN files from the MF to the BGW folder.
mf=1-mf-qe
bgw=2-bgw

# First, link all CD files
echo "Linking pseudopotential and charge densities"
for directory in {2,4}*-*/; do
  echo " Working on directory $directory"
  cd $directory
  mkdir -p Si.save
  # FHJ: Note that some links may remain broken, but that's fine.
  # We try to maximize compatibility across different versions of QE.
  ln -sf ../../1-scf/Si.save/charge-density.dat Si.save/
  ln -sf ../../1-scf/Si.save/data-file.xml Si.save/
  ln -sf ../../1-scf/Si.save/data-file-schema.xml Si.save/
  ln -sf ../1-scf/Si.UPF .
  cd ../
done
echo

echo "Linking WFNs to BGW directory"
cd ../$bgw/

echo " Working on directory 1-epsilon"
cd 1-epsilon/
ln -sf ../../$mf/2.1-wfn/WFN WFN
ln -sf ../../$mf/2.2-wfnq/WFN WFNq
cd ../

echo " Working on directory 2-sigma"
cd 2-sigma/
ln -sf ../../$mf/2.1-wfn/RHO .
ln -sf ../../$mf/2.1-wfn/WFN WFN_inner
ln -sf ../../$mf/2.1-wfn/vxc.dat .
cd bandstructure/
ln -sf ../../../$mf/2.1-wfn/WFN WFN_co
ln -sf ../../../$mf/4-bandstructure/WFN WFN_fi
cd ..
cd ..

echo
echo "Done!"
