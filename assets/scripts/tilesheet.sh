#!/bin/bash
#
# Script to take the sprite sheet in PNG format and output it as
# an asm file.
#
set -u
#set -e

function usage() {
	echo "Usage: $0 <tile sheet> <asm file>"
	echo
}

function c_to_asm() {
	inputFile=$1
	outputFile=$2

	mkdir -p $(dirname -- $outputFile)

	echo "Converting to assembly..."
	zcc +zx -S "$inputFile" -o "$outputFile"

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

tileSheet=$1

temp=`mktemp -d $PWD/tmp.XXXXX`
#mkdir -p temp
#temp=temp

# Width and Height in pixels
tileWidth=8
tileHeight=8

# Width and Height in tiles
width=16
height=16

tileSet=tiles.c

echo "/* Autogenerated tileset */" > $temp/$tileSet

tile=0
y=0
while [ $y -lt $height ]
do
	x=0
	while [ $x -lt $width ]
	do
		tx=$(($x*$tileWidth))
		ty=$(($y*$tileHeight))
#		echo "Tile X=$tx,Y=$ty -> $temp/tile${tile}.h"

		convert $tileSheet -colorspace Gray -threshold 1% -crop ${tileWidth}x${tileHeight}+$tx+$ty $temp/tile${tile}.png
		convert -set comment "" $temp/tile${tile}.png -negate -alpha off $temp/tile${tile}.h
		
		sed -i s/MagickImage/tile${tile}/ $temp/tile${tile}.h
		sed -i "s/^\s*0x50, 0x34, 0x0A, 0x23, 0x0A, 0x38, 0x20, 0x38, 0x0A, //g" $temp/tile${tile}.h
#		sed -i "s/0x50, 0x34, 0x0A,.*0x0A,.*0x0A, //g" $temp/tile${tile}.h
		sed -i "s/static //" $temp/tile${tile}.h
		echo "#include \"tile${tile}.h\"" >> $temp/$tileSet

		tile=$(($tile+1))
		x=$(($x+1))		
	done
	y=$(($y+1))
done

c_to_asm "$temp/$tileSet" "$2"

rm -rf $temp
echo "Done"
