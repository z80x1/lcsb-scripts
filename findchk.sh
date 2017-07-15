#!/bin/bash

set -x

LIST=$2
if [ -z $LIST ]; then
    LIST=list
fi
OUTDIR=$1
if [ -z $OUTDIR ]; then
    OUTDIR=`pwd`
fi

cat $LIST| while read line; do                    
    mv -v `locate $line.chk` $OUTDIR 
done 

#elist=$(cat $LIST)
#for str in $elist; 
#do
#    locate `sed -n "1 p" list`.chk
#    mv -v `locate $str.chk` $outdir 
#done;
