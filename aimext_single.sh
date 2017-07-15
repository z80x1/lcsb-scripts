#!/bin/bash
#This is much faster than using aimqb.exe like in batch.bat 

AIM="/var/local/AIMAll"
export LD_LIBRARY_PATH="$AIM/lib":$LD_LIBRARY_PATH

if [ -z "$1" ]; then
  echo "input file is not specified"
  exit
fi

f=$1
echo "processing $f"
$AIM/bin/aimext.exe $f -input Auto 1   6  1 0 1.0  2 0 8.0  3 0 8.0  4 0 8.0  0   1 0 0 20 6.0  0   0   99 > /dev/null


#rem Typical calculation decoding
#rem Auto        title
#rem 1           Calculation type: rho
#rem 20          ???


#rem 6           mega search

#rem 1           nuclear CP
#rem 0           all atoms
#rem 1.0         distance

#rem 2           atoms pairs
#rem 0           all atoms
#rem 8.0         distance

#rem 3           atoms triads
#rem 0           all atoms
#rem 8.0         distance
    
#rem 4           atoms quads
#rem 0           all atoms
#rem 8.0         distance

#rem 0           return


#rem 1           search along line
#rem 0           all atoms
#rem 0           all atoms
#rem 20          number of starting points
#rem 6.0         allowable distance

#rem 0           return


#rem 1           search over all atom-centered spheres
#rem 0           all atoms
#rem 8           NPhi
#rem 4           NTheta
#rem 0.2         RadMin
#rem 3.0         RadMax
#rem 10          NRatPt

#rem 0           return


#rem 6           mega search
#rem 2           atoms pairs
#rem 0           all atoms
#rem 20.0        maximum distance

#rem 0           return


#rem 0           return

