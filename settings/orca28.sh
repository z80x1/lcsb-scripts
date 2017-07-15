export ORCADIR=/var/local/orca
#for omega directory is different
export MPIDIR=/usr/bin
#export MPIDIR=/var/local/openmpi-1.4.2
export PATH=${PATH}:$ORCADIR:$MPIDIR/bin
export LD_LIBRARY_PATH=$MPIDIR/lib:$LD_LIBRARY_PATH
