.PHONY: clean all
all: build/levels.inc build/banner.inc build/tilesheet.inc build/RightKnight.inc

clean:
	rm -rf build

build/%.inc: tiled/%.tmx
	mkdir -p $(@D)
	tiled --export-map csv $< $<.tmp
	./scripts/csv2asm.sh $<.tmp $@
	rm $<.tmp

build/tilesheet.inc: gimp/tilesheet.png
	mkdir -p $(@D)
	./scripts/tilesheet.sh $< $@

build/RightKnight.inc: gimp/RightKnight.png gimp/RightMasks.png
	mkdir -p $(@D)
	./scripts/genSprites.sh gimp/RightKnight.png gimp/RightMasks.png -o $@
	rm ./build/*.bak
