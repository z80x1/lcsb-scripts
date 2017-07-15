#!/bin/bash
#Finds non-completed jobs

#set -x

argsnum=1
if [ $# -gt 0 ]; then
	argsnum=$1
fi

grep -c Normal *out | grep -v ":$argsnum" | sed 's/-\S*/.gjf/'
