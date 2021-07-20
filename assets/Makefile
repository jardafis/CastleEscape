.PHONY: clean all install
all: build/levels.inc \
	build/banner.inc \
	build/tilesheet.inc \
	build/RightKnight.inc \
	build/LeftKnight.inc \
	build/RightJumpKnight.inc \
	build/LeftJumpKnight.inc

clean:
	rm -rf build

install: all
	cp build/*Knight.inc ../src/sprite
	cp build/tilesheet.inc ../src/sprite
	cp build/levels.inc ../src
	cp build/banner.inc ../src

build/%.inc: tiled/%.tmx
	./scripts/tmx2asm.sh $< $@

build/tilesheet.inc: gimp/tilesheet.png
	./scripts/tilesheet.sh $< $@

build/RightKnight.inc: gimp/RightKnight.png gimp/RightMasks.png
	./scripts/genSprites.sh $^ -o $@

build/LeftKnight.inc: gimp/LeftKnight.png gimp/LeftMasks.png
	./scripts/genSprites.sh $^ -o $@

build/RightJumpKnight.inc: gimp/RightJump.png gimp/RightJumpMask.png
	./scripts/genSprites.sh $^ -o $@

build/LeftJumpKnight.inc: gimp/LeftJump.png gimp/LeftJumpMask.png
	./scripts/genSprites.sh $^ -o $@
	