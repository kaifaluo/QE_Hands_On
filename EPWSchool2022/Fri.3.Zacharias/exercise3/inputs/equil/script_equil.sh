#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=56
#SBATCH -A EPW-SCHOOL
cd $PWD
PATHQE=/path_to/q-e/ # this is the path to q-e
prefix=equil-si
i=1 # initial kpt index to calculate
f=30 # final kpt index to calculate
while [ $i -le $f ];do
  #
  JNAME=equil-nscf_333
  awk 'NR == '$i'' K_list.in > K_point.txt
  cat $JNAME K_point.txt > "$JNAME"_"$i".in
  #
  mkdir kpt_$i
  cd kpt_$i
  #
  EXE=$PATHQE/bin/pw.x
  #
  cp -r ../"$prefix".save .
  mv ../"$JNAME"_"$i".in .
  ibrun -n 14 $EXE < "$JNAME"_"$i".in > "$JNAME"_"$i".out
  #
  EXE=$PATHQE/bin/epsilon_Gaus.x
  JNAME=epsilon
  #
  cp ../"$JNAME".in .
  sed -i 's/tmp/'$i'/g' $JNAME.in
  ibrun -n 14 $EXE < "$JNAME".in > "$JNAME".out
  #
  rm -r *wfc* "$prefix".save
  cd ../
  i=$((i+1))
done

