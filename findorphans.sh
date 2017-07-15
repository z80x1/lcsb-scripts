#!/bin/bash

#set -x

EXTORPH=$2
if [ -z $EXTORPH ]; then
    EXTORPH=extout
fi

EXTNORM=$1
if [ -z $EXTNORM ]; then
    EXTNORM=wfn
fi

for ex in `ls *.$EXTNORM`; do                    
    tofind=$(echo $ex | sed "s/\.\S*/.$EXTORPH/")
    if [ ! -e $tofind ]; then
	echo $ex
    fi
done 
