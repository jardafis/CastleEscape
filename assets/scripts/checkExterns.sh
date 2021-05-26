#!/bin/bash

#
# Check the files passed in on the command line for unused 'externs'
#

if [ $# = 0 ]
then
	echo "Usage: $0 <file> [file]..."
	exit 0
fi

# Loop through all the files on the command line
while [ $1 ] 
do
	file=$1
	echo "Processing $file"
	for extern in `grep "^\s*extern\s*" $file | awk '{print $2}'`
	do
		if [ `grep -c $extern $file` = 1 ]
		then
			# Make a backup of the file
			cp $file ${file}.bak
			# Remove the unused externs
			echo "    Unused 'extern $extern' removed"
			sed -i "/^\s*extern\s*$extern.*/d" $file
		fi
	done
	# Next command line parameter
	shift;
done
