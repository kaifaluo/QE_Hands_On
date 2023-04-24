#!/bin/bash -l

# This serial script links the epsmat.h5 and bsemat files.

echo "Linking epsmat.h5 files"
for directory in {3,4}-*/; do
  echo " Working on directory $directory"

  cd $directory
  ln -sf ../1-epsilon/epsmat.h5 ./
  ln -sf ../1-epsilon/eps0mat.h5 ./
  cd ../
done

cd 4-absorption/
ln -sf ../3-kernel/bsemat.h5 ../4-absorption
cd ..

echo
echo "Done!"
