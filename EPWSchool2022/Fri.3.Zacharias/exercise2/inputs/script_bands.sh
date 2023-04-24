#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=56
#SBATCH -A EPW-SCHOOL
#SBATCH --partition=small
cd $PWD
PATHQE=/path_to/q-e/
prefix=ZG-si
i=1 # initial kpt index to calculate
f=35 # final kpt index to calculate
#
while [ $i -le $f ];do
  mkdir kpt_$i
  cd kpt_$i
  #
  EXE=$PATHQE/bin/pw.x
  JNAME=ZG-bands_333_0.00K_21.in
  #
  cp -r ../"$prefix".save .
  mv ../"$JNAME"_"$i".in .
  ibrun -n 14 $EXE < "$JNAME"_"$i".in > "$JNAME"_"$i".out
  #
  EXE=$PATHQE/bin/bands_unfold.x
  JNAME=bands
  #
  cp ../"$JNAME".in .
  sed -i 's/tmp/'$i'/g' $JNAME.in
  ibrun -n 14 $EXE < "$JNAME".in > "$JNAME".out
  #
  rm -r *wfc* "$prefix".save
  cd ../
  i=$((i+1))
done
