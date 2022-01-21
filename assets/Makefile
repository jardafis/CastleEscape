.PHONY: clean all install zxn

all: build/levels.inc \
	build/banner.inc \
	build/tilesheet.inc \
	build/RightKnight.inc \
	build/LeftKnight.inc \
	build/RightJumpKnight.inc \
	build/LeftJumpKnight.inc \
	build/ZXN_Sprites.spr \
	build/tilesheet.nxt

clean:
	rm -rf build

install: all
	cp build/*Knight.inc ../src/sprite
	cp build/tilesheet.inc ../src/sprite
	cp build/levels.inc ../src
	cp build/banner.inc ../src
	cp build/tilesheet.nxp ../src/sprite
	cp build/tilesheet.nxt ../src/sprite
	cp build/ZXN_Sprites.spr ../src/sprite
	cp build/ZXN_Sprites.nxp ../src/sprite

build/tilesheet.nxt: build/tilesheet.png Gfx2Next/bin/gfx2next 
	./Gfx2Next/bin/gfx2next -pal-min -preview -map-none -colors-4bit -tile-size=8x8 $<

build/ZXN_Sprites.spr: build/ZXN_Sprites.png Gfx2Next/bin/gfx2next
	./Gfx2Next/bin/gfx2next -preview -colors-4bit -sprites  $<

build/tilesheet.png: gimp/tilesheet.png
	convert $< PNG8:$@

build/ZXN_Sprites.png: gimp/ZXN_Sprites.png
	convert $< PNG8:$@

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
	
