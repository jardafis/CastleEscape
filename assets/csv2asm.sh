#!/bin/bash

if [ $# != 2 ]
then
	echo "Usage: csv2asm.sh <input file> <output file>"
	exit
fi

cat $1 | sed "s/^/        db      /g" > ${1}.tmp
cat ${1}.tmp | sed "s/-1/11/g" > ${2}
rm ${1}.tmp
