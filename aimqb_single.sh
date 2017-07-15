#!/bin/bash

AIM="/var/local/AIMAll"
export LD_LIBRARY_PATH="$AIM/lib":$LD_LIBRARY_PATH

if [ -z "$1" ]; then
  echo "input file is not specified"
  exit
fi
if [ -z "$2" ]; then
  skipint="true"
else
  skipint=$2
fi

f=$1
echo "processing $f"
#$AIM/bin/aimqb.exe $f -nogui -skipint=true -wsp=false -nproc=2> /dev/null
$AIM/bin/aimqb.exe $f -nogui -skipint=$skipint -nproc=2> /dev/null
