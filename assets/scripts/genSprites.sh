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

function c_to_asm() {
	inputFile=$1
	outputFile=$2

	mkdir -p $(dirname -- $outputFile)

	echo "Converting to assembly..."
	zcc +zx -S $inputFile -o $outputFile

	echo "Formatting..."
	# Remove comments
	sed -i -e "/^\s*;/d" $outputFile
	# Remove blank lines
	sed -i -e "/^$/d" $outputFile
	# Remove lines containing unneeded directives
	sed -i -e "/^\s*[C_LINE|SECTION|MODULE|INCLUDE|GLOBAL]/d" $outputFile
	# Remove underscores
	sed -i -e "s/._/./" $outputFile

	which z88dk-asmstyle > /dev/null
	if [ $? = 0 ]
	then
		z88dk-asmstyle $outputFile
	else
		asmstyle.pl $outputFile
	fi
	rm ${outputFile}.bak

	return 0
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
#mkdir temp
echo "Creating $temp"

frame=0
ty=0
echo "/* Autogenerated by $0 */" > $temp/${spriteFileName}.c 

while [ $frame -lt $numFrames ]
do
	echo "Creating frame $frame"
	
	tx=$((frame*spriteByteWidth*8))
	n=0
	while [ $n -lt $spriteByteWidth ]
	do
		convert $maskSheet -colorspace Gray -threshold 1% -crop 8x16+$tx+$ty $temp/${maskFileName}$n.png
		convert $spriteSheet -colorspace Gray -threshold 1% -crop 8x16+$tx+$ty $temp/${spriteFileName}$n.png
		tx=$((tx+=8))
		n=$((n+1))
	done

	convert \
		$temp/${maskFileName}0.png $temp/${spriteFileName}0.png \
		$temp/${maskFileName}1.png $temp/${spriteFileName}1.png \
		$temp/${maskFileName}2.png $temp/${spriteFileName}2.png \
		+append $temp/interlace.png

	convert -set comment "" $temp/interlace.png -negate -alpha off $temp/${spriteFileName}$frame.h

	# Clean up the header file
	sed -i s/MagickImage/$(basename -- ${spriteSheet%.png}$frame)/ $temp/${spriteFileName}$frame.h
	# Remove PNM header
	sed -i "s/^\s*0x50, 0x34, 0x0A,.*0x0A,.*0x0A, /    /" $temp/${spriteFileName}$frame.h
	# Remove the static directive
	sed -i "s/static //" $temp/${spriteFileName}$frame.h
	# Add the header to C source file
	echo "#include \"${spriteFileName}$frame.h\"" >> $temp/${spriteFileName}.c
	
	frame=$((frame+1))
done

c_to_asm "$temp/${spriteFileName}.c" "$outFile"

echo "Removing $temp"
rm -rf $temp