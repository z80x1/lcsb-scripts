#!/bin/bash
#This is much faster than using aimqb.exe like in batch.bat 

early()
{
  echo ' '
  echo ' ############ WARNING:  EARLY TERMINATION #############'
  echo ' '
  exit
}

trap 'early' 2 9 15

if [ -n "$1" ]; then
  cd $1
fi

for f in `ls *.wfn`;
do 
  aimext_single.sh $f
done;

popd
