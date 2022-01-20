.PHONY: clean all install zxn

all: build/levels.inc \
	build/banner.inc \
	build/tilesheet.inc \
	build/RightKnight.inc \
	build/LeftKnight.inc \
	build/RightJumpKnight.inc \
	build/LeftJumpKnight.inc \
	zxn

clean:
	rm -rf build

install: all
	cp build/*Knight.inc ../src/sprite
	cp build/tilesheet.inc ../src/sprite
	cp build/levels.inc ../src
	cp build/banner.inc ../src
	cp build/tilesheet.nxp ../src/sprite
	cp build/tilesheet.nxt ../src/sprite

zxn: Gfx2Next/bin/gfx2next
	mkdir -p build
	./Gfx2Next/bin/gfx2next -pal-min -preview -map-none -colors-4bit -tile-size=8x8 gimp/tilesheet.png build/tilesheet

Gfx2Next:
	git clone --depth=1 https://github.com/headkaze/Gfx2Next.git

Gfx2Next/bin/gfx2next: Gfx2Next
	sed -i 's/\(^\s*gcc.*$$\)/\1 -lm/g' Gfx2Next/Makefile
	make -C Gfx2Next

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
	
