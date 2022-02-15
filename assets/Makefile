.PHONY: clean all install zxn

all: build Gfx2Next/bin/gfx2next \
	build/levels.nxm \
	build/banner.nxm \
	build/RightKnight.raw \
	build/LeftKnight.raw \
	build/RightJumpKnight.raw \
	build/RightFallKnight.raw \
	build/LeftJumpKnight.raw \
	build/LeftFallKnight.raw \
	build/ZXS_tilesheet.nxt \
	build/ZXN_Sprites.spr \
	build/ZXN_tilesheet.nxt

clean:
	rm -rf build

install: all
	cp build/*Knight.raw ../src/sprite
	cp build/levels.nxm ../src
	cp build/banner.nxm ../src
	cp build/ZXS_tilesheet.nxt ../src/sprite
	cp build/ZXN_tilesheet.nxp ../src/sprite
	cp build/ZXN_tilesheet.nxt ../src/sprite
	cp build/ZXN_Sprites.spr ../src/sprite
	cp build/ZXN_Sprites.nxp ../src/sprite

build:
	mkdir -p $@

build/ZXN_tilesheet.nxt: build/tilesheet.png
	./Gfx2Next/bin/gfx2next -pal-min -map-none -colors-4bit -tile-size=8x8 $< $@

build/ZXN_Sprites.spr: build/ZXN_Sprites.png
	./Gfx2Next/bin/gfx2next -pal-min -colors-4bit -sprites $< $@

build/tilesheet.png: gimp/tilesheet.png
	convert $< PNG8:$@

build/ZXN_Sprites.png: gimp/ZXN_Sprites.png
	convert $< PNG8:$@

Gfx2Next:
	git clone --depth=1 https://github.com/headkaze/Gfx2Next.git

Gfx2Next/bin/gfx2next: Gfx2Next
	make -C Gfx2Next

build/%.nxm: tiled/%.tmx
	cd tiled && ../Gfx2Next/bin/gfx2next -tiled -pal-none -tile-none -tiled-blank=11 $(<F) ../$@

build/ZXS_tilesheet.nxt: gimp/tilesheet.png
	./Gfx2Next/bin/gfx2next -pal-none -map-none -colors-1bit -tile-size=8x8 $< $@

build/RightKnight.raw: gimp/RightKnight.png gimp/RightMasks.png
	./scripts/genSprites.sh $^ -o $@

build/LeftKnight.raw: gimp/LeftKnight.png gimp/LeftMasks.png
	./scripts/genSprites.sh $^ -o $@

build/RightJumpKnight.raw: gimp/RightJump.png gimp/RightJumpMask.png
	./scripts/genSprites.sh $^ -o $@

build/RightFallKnight.raw: gimp/RightFall.png gimp/RightFallMask.png
	./scripts/genSprites.sh $^ -o $@

build/LeftJumpKnight.raw: gimp/LeftJump.png gimp/LeftJumpMask.png
	./scripts/genSprites.sh $^ -o $@
	
build/LeftFallKnight.raw: gimp/LeftFall.png gimp/LeftFallMask.png
	./scripts/genSprites.sh $^ -o $@
