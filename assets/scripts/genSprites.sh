#!/bin/bash

function usage() {
	echo "Usage: $0 <sprite sheet> <mask sheet> [OPTIONS]"
	echo
	echo "OPTIONS:"
	echo "    -h           Display this text."
	echo "    -o <string>  Specify output asm file name."
	echo "    -f <int>     Number of frames contained in image files."
	echo "    -w <int>     Width of the sprite is bytes."
	echo
}

if [ $# -lt 2 ]
then
	usage
	exit 0
fi

argArray=( "$@" )

if [ ! -e ${argArray[0]} ]
then
	echo "${argArray[0]} : file does not exist!"
	exit 1
fi

if [ ! -e ${argArray[1]} ]
then
	echo "${argArray[1]} : file does not exist!"
	exit 1
fi

# Set default parameters
spriteSheet=${argArray[0]}
maskSheet=${argArray[1]}
spriteFileName=$(basename -- $spriteSheet .png)
maskFileName=$(basename -- $maskSheet .png)
outFile=${spriteSheet%.png}.inc
numFrames=8
spriteByteWidth=3

# Process command line starting at parameter #2
n=2
while [ "${argArray[n]}" != "" ]
do
	case "${argArray[n]}" in
	-o)
	   	n=$((n+1))
		outFile="${argArray[n]}"
		;;
	-f)
	   	n=$((n+1))
		numFrames="${argArray[n]}"
		;;
	-w)
	   	n=$((n+1))
		spriteByteWidth="${argArray[n]}"
		;;
	*)
		echo "Unknown parameter: ${argArray[n]}"
		usage
		exit 1
		;;
	esac
   n=$((n+1))
done

temp=`mktemp -d $PWD/tmp.XXXXX`
#temp=temp
#mkdir -p temp
echo "Creating $temp"

frame=0
ty=0

while [ $frame -lt $numFrames ]
do
	echo "Creating frame $frame"
	
	tx=$((frame*spriteByteWidth*8))
	n=0
	while [ $n -lt $spriteByteWidth ]
	do
		convert $maskSheet -colorspace Gray -threshold 1% -crop 8x16+$tx+$ty PNG8:$temp/${maskFileName}$n.png
		convert $spriteSheet -colorspace Gray -threshold 1% -crop 8x16+$tx+$ty PNG8:$temp/${spriteFileName}$n.png
		tx=$((tx+=8))
		n=$((n+1))
	done

	convert \
		$temp/${maskFileName}0.png $temp/${spriteFileName}0.png \
		$temp/${maskFileName}1.png $temp/${spriteFileName}1.png \
		$temp/${maskFileName}2.png $temp/${spriteFileName}2.png \
		+append PNG8:$temp/interlace_${spriteFileName}$frame.png
	
	frame=$((frame+1))
done

convert $temp/interlace_${spriteFileName}0.png \
		$temp/interlace_${spriteFileName}1.png \
		$temp/interlace_${spriteFileName}2.png \
		$temp/interlace_${spriteFileName}3.png \
		$temp/interlace_${spriteFileName}4.png \
		$temp/interlace_${spriteFileName}5.png \
		$temp/interlace_${spriteFileName}6.png \
		$temp/interlace_${spriteFileName}7.png \
	-append PNG8:$temp/interlace_${spriteFileName}.png

convert $temp/interlace_${spriteFileName}.png -depth 1 GRAY:$outFile

echo "Removing $temp"
rm -rf $temp
