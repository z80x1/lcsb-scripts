#!/bin/bash

#set -x

#rm joblist

ls *gjf | while read line; do 
	ls $(echo $line|sed 's/\.\S*//')*out &> /dev/null || echo $line   ; 
done
