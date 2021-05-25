.PHONY: clean all install
all: build/levels.inc build/banner.inc build/tilesheet.inc build/RightKnight.inc build/LeftKnight.inc

clean:
	rm -rf build

install: all
	cp build/*Knight.inc ../src/sprite
	cp build/tilesheet.inc ../src/sprite
	cp build/levels.inc ../src
	cp build/banner.inc ../src

build/%.inc: tiled/%.tmx
	tiled --export-map csv $< $<.tmp
	./scripts/csv2asm.sh $<.tmp $@
	rm $<.tmp

build/tilesheet.inc: gimp/tilesheet.png
	./scripts/tilesheet.sh $< $@

build/RightKnight.inc: gimp/RightKnight.png gimp/RightMasks.png
	./scripts/genSprites.sh $^ -o $@

build/LeftKnight.inc: gimp/LeftKnight.png gimp/LeftMasks.png
	./scripts/genSprites.sh $^ -o $@

