.PHONY: clean all install

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
	@cp -v build/*.nxm ../src
	@cp -v build/*.raw ../src/sprite
	@cp -v build/*.nxt ../src/sprite
	@cp -v build/*.nxp ../src/sprite
	@cp -v build/*.spr ../src/sprite

build:
	mkdir -p $@

build/ZXN_tilesheet.nxt: build/tilesheet.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-min -map-none -colors-4bit -tile-size=8x8 $< $@

build/ZXN_Sprites.spr: build/ZXN_Sprites.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-min -colors-4bit -sprites $< $@

build/tilesheet.png: gimp/tilesheet.png
	convert $< PNG8:$@

build/ZXN_Sprites.png: gimp/ZXN_Sprites.png
	convert $< PNG8:$@

Gfx2Next/bin/gfx2next:
	git clone --depth=1 https://github.com/headkaze/Gfx2Next.git
	make -C Gfx2Next

build/%.nxm: tiled/%.tmx
	@echo "Creating $@"
	@cd tiled && ../Gfx2Next/bin/gfx2next -tiled -pal-none -tile-none -tiled-blank=11 $(<F) ../$@

build/ZXS_tilesheet.nxt: gimp/tilesheet.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-none -map-none -colors-1bit -tile-size=8x8 $< $@

build/RightKnight.raw: gimp/RightKnight.png gimp/RightMasks.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/LeftKnight.raw: gimp/LeftKnight.png gimp/LeftMasks.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/RightJumpKnight.raw: gimp/RightJump.png gimp/RightJumpMask.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/RightFallKnight.raw: gimp/RightFall.png gimp/RightFallMask.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/LeftJumpKnight.raw: gimp/LeftJump.png gimp/LeftJumpMask.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@
	
build/LeftFallKnight.raw: gimp/LeftFall.png gimp/LeftFallMask.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@
