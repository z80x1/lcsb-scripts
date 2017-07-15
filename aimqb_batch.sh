#!/bin/bash

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
  aimqb_single.sh $f $2
done;

popd
