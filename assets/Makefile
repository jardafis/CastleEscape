.PHONY: clean all install zxn

all: build/levels.inc \
	build/banner.inc \
	build/RightKnight.inc \
	build/LeftKnight.inc \
	build/RightJumpKnight.inc \
	build/RightFallKnight.inc \
	build/LeftJumpKnight.inc \
	build/LeftFallKnight.inc \
	build/ZXS_tilesheet.nxt \
	build/ZXN_Sprites.spr \
	build/ZXN_tilesheet.nxt

clean:
	rm -rf build

install: all
	cp build/*Knight.inc ../src/sprite
	cp build/levels.inc ../src
	cp build/banner.inc ../src
	cp build/ZXS_tilesheet.nxt ../src/sprite
	cp build/ZXN_tilesheet.nxp ../src/sprite
	cp build/ZXN_tilesheet.nxt ../src/sprite
	cp build/ZXN_Sprites.spr ../src/sprite
	cp build/ZXN_Sprites.nxp ../src/sprite

build/ZXN_tilesheet.nxt: build/tilesheet.png Gfx2Next/bin/gfx2next
	./Gfx2Next/bin/gfx2next -pal-min -map-none -colors-4bit -tile-size=8x8 $< $@

build/ZXN_Sprites.spr: build/ZXN_Sprites.png Gfx2Next/bin/gfx2next
	./Gfx2Next/bin/gfx2next -pal-min -colors-4bit -sprites $< $@

build/tilesheet.png: gimp/tilesheet.png
	convert $< PNG8:$@

build/ZXN_Sprites.png: gimp/ZXN_Sprites.png
	convert $< PNG8:$@

Gfx2Next:
	git clone --depth=1 https://github.com/headkaze/Gfx2Next.git

Gfx2Next/bin/gfx2next: Gfx2Next
	make -C Gfx2Next

build/%.inc: tiled/%.tmx
	./scripts/tmx2asm.sh $< $@

build/ZXS_tilesheet.nxt: gimp/tilesheet.png Gfx2Next/bin/gfx2next
	./Gfx2Next/bin/gfx2next -map-none -colors-1bit -tile-size=8x8 $< $@

build/tilesheet.inc: gimp/tilesheet.png
	./scripts/tilesheet.sh $< $@

build/RightKnight.inc: gimp/RightKnight.png gimp/RightMasks.png
	./scripts/genSprites.sh $^ -o $@

build/LeftKnight.inc: gimp/LeftKnight.png gimp/LeftMasks.png
	./scripts/genSprites.sh $^ -o $@

build/RightJumpKnight.inc: gimp/RightJump.png gimp/RightJumpMask.png
	./scripts/genSprites.sh $^ -o $@

build/RightFallKnight.inc: gimp/RightFall.png gimp/RightFallMask.png
	./scripts/genSprites.sh $^ -o $@

build/LeftJumpKnight.inc: gimp/LeftJump.png gimp/LeftJumpMask.png
	./scripts/genSprites.sh $^ -o $@
	
build/LeftFallKnight.inc: gimp/LeftFall.png gimp/LeftFallMask.png
	./scripts/genSprites.sh $^ -o $@
