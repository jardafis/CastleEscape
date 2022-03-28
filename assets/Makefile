.PHONY: clean all install

all: build \
	Gfx2Next/bin/gfx2next \
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

build/ZXN_Sprites.spr: build/ZXN_Sprites.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-min -colors-4bit -sprites $< $@

Gfx2Next/bin/gfx2next:
	git clone --depth=1 https://github.com/headkaze/Gfx2Next.git
	make -C Gfx2Next

build/%.nxm: tiled/%.tmx
	@echo "Creating $@"
	@convert gimp/tilesheet.png PNG8:gimp/tilesheet.png
	@cd tiled && ../Gfx2Next/bin/gfx2next -tiled -pal-none -tile-none -tiled-blank=11 $(<F) ../$@

build/ZXN_tilesheet.nxt: build/tilesheet.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-min -map-none -colors-4bit -tile-size=8x8 $< $@

build/ZXS_tilesheet.nxt: build/tilesheet.png
	@echo "Creating $@"
	@./Gfx2Next/bin/gfx2next -pal-none -map-none -colors-1bit -tile-size=8x8 $< $@

build/RightKnight.raw: build/animation_2.png build/animation_8.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/LeftKnight.raw: build/animation_5.png build/animation_11.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/RightJumpKnight.raw: build/animation_1.png build/animation_7.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/RightFallKnight.raw: build/animation_0.png build/animation_6.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/LeftJumpKnight.raw: build/animation_4.png build/animation_10.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@
	
build/LeftFallKnight.raw: build/animation_3.png build/animation_9.png
	@echo "Creating $@"
	@./scripts/genSprites.sh $^ -o $@

build/%.png: gimp/%.xcf
	./scripts/xcf2png.sh $< $@
	convert $@ PNG8:$@

build/animation_%.png: gimp/animation.xcf
	./scripts/xcf2layers.sh $< build/animation.gif
	convert build/animation.gif build/animation_%d.png
