#!/bin/bash
if [ -z $1 ]; then
   echo "usage: $0 <max num of jobs in medium queue>"
   exit 1;
fi

qmgr -c "set queue medium max_running = $1";
