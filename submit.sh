#!/bin/bash

#http://www.linuxjournal.com/content/floating-point-math-bash
# Floating point number functions.
#####################################################################
# Default scale used by float functions.
float_scale=2
#####################################################################
# Evaluate a floating point number expression.
function float_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}
#####################################################################
# Evaluate a floating point number conditional expression.
function float_cond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}

COMMAND="$1"
shift
if [ -z $COMMAND ]; then
    echo error: no QM program specified
    echo "usage: go to the directory with input files and run from there"
    echo "$0 <command> <qsub parameters>"
    echo "All found input files in current directory will be submitted to PBS"
    echo "Also you can manually create file named 'joblist' containing list of input files you want to be calculated and then run submit.sh script"
    echo "<command> can be one of following: g03, g09, orca29, orca30, aimext" 
    echo "  g03 is for calculating with Gaussian 03 E.01"
    echo "  g09 - Gaussian 09 B.01,"
    echo "  orca29 - Orca version 2.9"
    echo "  orca30 - Orca version 3.0.x"
    echo "  aimext - calculation of AIM parameters from .wfn files with AIMAll.111219" 
    echo "Most important <qsub parameters> value is job estimated time to run: -l walltime=h:mm:ss but almost any other parameter can be used."
    echo "Threads counts and memory limit for Gaussian are determined automatically from first .gjf file in directory"
    echo "Threads counts and memory limit for Orca are determined automatically from first .inp file in directory"
    exit 1;
fi
SCRIPTDIR=/var/local/bin

#parsing custom user
CUSTOM_USER_SCRIPT=
if [[ -n $1 && ${1:0:1} != '-' ]]; then
    CUSTOM_USER_SCRIPT="$1"
    shift
fi

#trying to change working directory to shared one
cd $(echo $PWD | sed "s=/home/$USER=/shared/$USER=")

curdir=${PWD##*/}
if [ -n "$(echo $curdir | grep [\(\)])" ];
then
    echo Directory name where jobs are submitted must not contain round brackets
    exit 1;
fi

INFILE0=joblist
export INFILE=$INFILE0.$(date '+%m%d%H%M%S')

#need to be explored
#-V Specify that all of the environment variables of the process are exported to the context of the batch job
#-N name
#-j join_list
QSUBARGS="-V -j oe -N $curdir"

case $COMMAND in
g03|g09)
    FILEMASK="*.gjf"
    if [ ! -f $INFILE0 ]; then 
	if ! ls $FILEMASK > $INFILE0; then
		echo No files found - nothing to do
		exit 1
	fi 
    fi
    cp $INFILE0 $INFILE
    dos2unix -q $INFILE
    if [ ! -f $INFILE ]; then exit; fi
    jobscount=$(wc $INFILE | awk '{print $2}')
    if [ $jobscount -gt 1 ]; then
	array="-t 1-$jobscount"
    fi

    nodespec=""
    if [ $COMMAND == g03 ]; then
    	export GAUSSVER=g03
    else
#TBD: set limit to 1 process for AMD Phenom node
    	export GAUSSVER=g09
        nodespec=":g09"
    fi 

    nproc=$(grep -i nproc $(cat $INFILE|head -n1)|head -n1|dos2unix|cut -d= -f2)
    if [ -z "$nproc" ]; then nproc=1; fi

    mem=$(grep -i mem $(cat $INFILE|head -n1)|head -n1|dos2unix|cut -d= -f2)
    if [ -z "$mem" ]; then mem=200m; fi

    qsub $QSUBARGS $array -l mem=$mem -l nodes=1:ppn=${nproc}${nodespec} "$@" $SCRIPTDIR/gaussian.pbs
    ;;

orca|orca29|orca30)
    FILEMASK="*.inp"
    if [ ! -f $INFILE0 ]; then	
	if ! ls $FILEMASK > $INFILE0; then
		echo No files found - nothing to do
		exit 1
	fi 
    fi
    cp $INFILE0 $INFILE
    dos2unix -q $INFILE
    if [ ! -f $INFILE ]; then exit; fi
    jobscount=$(wc $INFILE | awk '{print $2}')
    if [ $jobscount -gt 1 ]; then
	array="-t 1-$jobscount"
    fi
    if [ $COMMAND == orca30 ]; then
    	export PROGVER=orca30
    else
    	export PROGVER=orca
    fi 
    nodespec=":orca"

#export
    #%pal nprocs 2
#need to be changed for last field - nor third!!!
    nproc=$(grep -i nprocs $(cat $INFILE|head -n1)|awk '{print $NF}'|tr -d '\r')
    if [ -z "$nproc" ]; then nproc=1; fi
    #%MaxCore 8000
    mem=$(grep -i MaxCore $(cat $INFILE|head -n1)|awk '{print $NF}'|tr -d '\r')
    if [ -z "$mem" ]; then 
	mem=200m; 
    else
	#adding extra 20% overhead
#	mem=$(float_eval "$mem * $nproc * 1.1"|cut -d. -f1)m
	mem=$(float_eval "$mem * 1.1"|cut -d. -f1)m
    fi

    if [ -n "$CUSTOM_USER_SCRIPT" ]; then
        qsub $QSUBARGS -t 1-$jobscount -l mem=$mem -l nodes=1:ppn=${nproc}${nodespec} "$@" $CUSTOM_USER_SCRIPT
    else
        qsub $QSUBARGS -t 1-$jobscount -l mem=$mem -l nodes=1:ppn=${nproc}${nodespec} "$@" $SCRIPTDIR/orca.pbs
    fi
#    qsub $QSUBARGS  $array "$@" $SCRIPTDIR/orca.pbs
    ;;

aimext)
    if [ ! -f $INFILE0 ]; then	
	if ! ls *.wfn > $INFILE0; then
		echo No files found - nothing to do
		exit 1
	fi 
    fi
    cp $INFILE0 $INFILE
    dos2unix -q $INFILE
    if [ ! -f $INFILE ]; then exit; fi
    jobscount=$(wc $INFILE | awk '{print $2}')

    qsub $QSUBARGS -t 1-$jobscount -l mem=200m -l nodes=1 "$@" $SCRIPTDIR/aimext.pbs
    ;;

*)
    echo unknown QM program
    ;;
esac

#FIX print path for job monitoring on owncloud
echo $PWD | grep olya > /dev/null
if [ $? -eq 0 ]; then 
  echo -n "Path on owncloud for job: "
  echo $PWD | sed 's|^.*olya|https://lcsb.org.ua/owncloud/index.php/apps/files?dir=/Shared/olya|'
fi

