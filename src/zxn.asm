IF  _ZXN

        extern  tile_palette_end
        extern  tile_palette
        extern  spriteStart
        extern  spriteEnd
        extern  spritePalette
        extern  spritePaletteEnd

        public  zxnInit
        public  clearTilemap
        public  clearULATile
        public  enableSprite
        public  disableSprite
        public  setSpriteXY
        public  setSpritePattern
        public  nextSpritePattern
        public  setSpriteFlip
        public  updateSpriteAttribs
        public  getSpriteFlip
        public  spiderSprites
        public  setSpriteVFlip
        public  disableAllSprites
        public  knightSprite

        #include    "defs.inc"

        section CODE_2
        ;
        ; Initialize the ZX Spectrum Next hardware
        ;
        ; Input:
        ;   None.
        ;
zxnInit:
        nextreg IO_TurboMode, 0x00      ; CPU speed (0=3.5Mhz, 1=7Mhz, 2=14 Mhz )

        call    initTilemap

		; Page in the sprite data
        bank    spriteStart>>16
        ld      hl, spriteStart
        ld      bc, spriteEnd-spriteStart
        nextreg IO_SpriteNumber, 0x00   ; Select sprite index 0
        call    initSpritePatterns

        ;(R/W) 0x43 (67) => Palette Control
        ; bit 7 = '1' to disable palette write auto-increment.
        ; bits 6-4 = Select palette for reading or writing:
        ; 000 = ULA first palette
        ; 100 = ULA second palette
        ; 001 = Layer 2 first palette
        ; 101 = Layer 2 second palette
        ; 010 = Sprites first palette
        ; 110 = Sprites second palette
        ; 011 = Tilemap first palette
        ; 111 = Tilemap second palette
        ; bit 3 = Select Sprites palette (0 = first palette, 1 = second palette)
        ; bit 2 = Select Layer 2 palette (0 = first palette, 1 = second palette)
        ; bit 1 = Select ULA palette (0 = first palette, 1 = second palette)
        ; bit 0 = Enabe ULANext mode if 1. (0 after a reset)
        ; Sprites first palette
        nextreg IO_TileMapPaletteContr, %00100000
        ld      hl, spritePalette
        ld      b, spritePaletteEnd-spritePalette
        xor     a
        call    setPalette

        ret

        ;
        ; Program color data to the currently selected palette.
        ;
        ; Input:
        ;       hl - Pointer to palette data
        ;       b  - # of palette entries
        ;       a  - Palette start index
        ;
        ; Output:
        ;       hl, b, a - Corrupt
setPalette:
        nextreg IO_PaletteIndex, a      ; Palette index
nextColor:
        ld      a, (hl)                 ; get the colour from the palette array
        inc     hl                      ; next element in the array
        nextreg IO_PaletteValue, a      ; write color to palette
        djnz    nextColor               ; next color
        ret

        ;
        ; Program color data to the currently selected palette.
        ; Color data is 9 bit data, which means 2 bytes per color.
        ; Only the LSB of each color is used.
        ;
        ; Input:
        ;       hl - Pointer to palette data
        ;       b  - # of palette entries
        ;       a  - Palette start index
        ;
        ; Output:
        ;       hl, b, a - Corrupt
setTilePalette:
        nextreg IO_PaletteIndex, a      ; Palette index
nextTileColor:
        ld      a, (hl)                 ; get the colour from the palette array
        inc     hl                      ; next element in the array
        inc     hl
        nextreg IO_PaletteValue, a      ; write color to palette
        djnz    nextTileColor           ; next color
        ret

        ;
        ; Fill the tilemap memory with a blank tile.
        ;
        ; Input:
        ;   None.
        ;
        ; Output:
        ;   bc, de, hl - Corrupt.
        ;
clearTilemap:
        ; Clear the tilemap area
        ld      hl, TILEMAP_START
        ld      (hl), ID_BLANK          ; Tile ID
        ld      de, TILEMAP_START+1
        ld      bc, TILEMAP_SIZE-1
        ldir
        ret

        ;
        ; Clear a character location in ULA memory.
        ;
        ; Input:
        ;   c - X char coord.
        ;   b - Y char coord.
        ;
clearULATile:
        push    bc
        push    de

        ld      de, bc

        ; Convert byte addresses to pixel addresses
        sla     d
        sla     d
        sla     d
        sla     e
        sla     e
        sla     e

        call    clearULATilePixel

        pop     de
        pop     bc
        ret

        ;
        ; Clear a character location in ULA memory specified by
        ; pixel location.
        ;
        ; Input:
        ;   e - X pixel coord.
        ;   d - Y pixel coord.
        ;
clearULATilePixel:
        push    bc
        push    hl

        pixelad

        ld      b, 8
clrULATileLoop:
        ld      (hl), 0
        inc     h
        djnz    clrULATileLoop

        pop     hl
        pop     bc
        ret

        ;
        ; Initialize and clear the tilemap hardware and memory.
        ;
        ; Input:
        ;   None.
        ;
initTilemap:
        call    clearTilemap

        ; Set the tilemap base address
        nextreg IO_TileMapBaseAdrr, TILEMAP_START>>8

        ; Set the tile definition base address
        nextreg IO_TileMapDefBaseAddr, TILEMAP_DEF_START>>8

;*___________________________________________________________________________________________________________________________________

        ; TILE MAP CONTROL
        ; bit 7    = 1 to enable the tilemap
        ; bit 6    = 0 for 40x32, 1 for 80x32
        ; bit 5    = 1 to eliminate the attribute entry in the tilemap
        ; bit 4    = palette select
        ; bits 3-2 = Reserved set to 0
        ; bit 1    = 1 to activate 512 tile mode
        ; bit 0    = 1 to force tilemap on top of ULA
        ; tile map with  attribute byte eliminated is selected, (bit 5 is 1)
        nextreg IO_TileMapContr, %10100000

;*___________________________________________________________________________________________________________________________________

        ; only used if no tile attrs in the tile map
        ; (R/W) 0x6C (108) => Default Tilemap Attribute
        ; bits 7-4 = Palette Offset
        ; bit 3    = X mirror
        ; bit 2    = Y mirror
        ; bit 1    = Rotate
        ; bit 0    = ULA over tilemap
        ; bit 8 of the tile number if 512 tile mode is enabled)
        nextreg IO_TileMapAttr, %00000000

;*___________________________________________________________________________________________________________________________________


        ; (R/W) 0x4C (76) => Transparency index for the tilemap
        ; bits 7-4 = Reserved, must be 0
        ; bits 3-0 = Set the index value (0xF after reset)

        ; bits 0-3 (0-15)
        nextreg IO_TileMapTransparency, %0000000

;*___________________________________________________________________________________________________________________________________


        ;(R/W) 0x43 (67) => Palette Control
        ; bit 7 = '1' to disable palette write auto-increment.
        ; bits 6-4 = Select palette for reading or writing:
        ; 000 = ULA first palette
        ; 100 = ULA second palette
        ; 001 = Layer 2 first palette
        ; 101 = Layer 2 second palette
        ; 010 = Sprites first palette
        ; 110 = Sprites second palette
        ; 011 = Tilemap first palette
        ; 111 = Tilemap second palette
        ; bit 3 = Select Sprites palette (0 = first palette, 1 = second palette)
        ; bit 2 = Select Layer 2 palette (0 = first palette, 1 = second palette)
        ; bit 1 = Select ULA palette (0 = first palette, 1 = second palette)
        ; bit 0 = Enabe ULANext mode if 1. (0 after a reset)
        ; Tilemap first palette
        nextreg IO_TileMapPaletteContr, %00110000
        xor     a                       ; Palette start index
        ; Number of colors
        ld      b, +(tile_palette_end-tile_palette)/2
        ld      hl, tile_palette        ; Pointer to palette
        call    setTilePalette          ; Do it!

;*___________________________________________________________________________________________________________________________________


        ; (R/W) 0x68 (104) => ULA Control
        ; bit 7 = 1 to disable ULA output
        ; bit 6 = 0 to select the ULA colour for blending in SLU modes 6 & 7
        ;       = 1 to select the ULA/tilemap mix for blending in SLU modes 6 & 7
        ; bits 5-1 = Reserved must be 0
        ; bit 0 = 1 to enable stencil mode when both the ULA and tilemap are enabled
        ; (if either are transparent the result is transparent otherwise the result is a logical AND of both colours)

        nextreg IO_ULAControl, %00000000

;*___________________________________________________________________________________________________________________________________
        ; There is no scrolling so set the tilemap
        ; offsets so that the first tile aligns
        ; with the first character position of the ULA.
        ; Meaning the first tile is at location 0,0
        nextreg IO_TileMapOffSetXMSB, 288>>8
        nextreg IO_TileMapOffSetXLSB, 288&0xff
        nextreg IO_TileMapOffsetY, 224

;*___________________________________________________________________________________________________________________________________

        ; Tilemap clipping. Match the ULA area
        ; X1 value internally doubled
        nextreg IO_TileMapClipWindow, 16
        ; X2 value internally doubled
        nextreg IO_TileMapClipWindow, 159-16
        ; Y1
        nextreg IO_TileMapClipWindow, 32
        ; Y2
        nextreg IO_TileMapClipWindow, 223

		; Enable sprites
        nextreg IO_SpriteAndLayers, 0x01

        ret

        ;
        ; Write sprite pattern data to the hardware.
        ;
        ; Input:
        ;   hl - Pointer to sprite pattern data
        ;   bc - Length, in bytes, of sprite pattern data
        ;
        ; Output:
        ;   af, bc - Corrupt.
        ;
initSpritePatterns:
        ld      a, b
        or      a
        jr      z, lastBlock            ; > 256 bytes

nextPatternBlock:
        push    bc
        ld      c, IO_SpritePattern     ; copy sprite data to through register 0x5B
        ld      b, 0                    ; do a 256 bytes which is 0 this and the prevous like could be bc,0x005b
        otir                            ; send that
        pop     bc
        djnz    nextPatternBlock

lastBlock:
        ld      a, c
        or      a
        ret     z                       ; No more bytes

        ld      c, IO_SpritePattern     ; copy sprite data to through register 0x5B
        ld      b, a
        otir                            ; send that

        ret

  IF    0
        ;
        ; Input:
        ;       None
        ;
        ; Output:
        ;       a, hl - Corrupt
        ;
setupSprites:
        ld      hl, spriteList
nextSprite:
        ld      a, (hl)
        cp      0x80
        ret     z

        inc     hl

        nextreg IO_SpriteNumber, a

        ld      a, (hl)
        inc     hl
        ; Sprite Attribute 0
        ; bits 7-0 = LSB of X coordinate
        nextreg IO_SpriteAttrib0, a

        ld      a, (hl)
        inc     hl
        ; Sprite Attribute 1
        ; bits 7-0 = LSB of Y coordinate
        nextreg IO_SpriteAttrib1, a

        ld      a, (hl)
        inc     hl
        ; Sprite Attribute 2
        ; bits 7-4 = Palette offset added to top 4 bits of sprite colour index
        ; bit 3 = X mirror
        ; bit 2 = Y mirror
        ; bit 1 = Rotate
        ; bit 0 = MSB of X coordinate
        nextreg IO_SpriteAttrib2, a

        ld      a, (hl)
        inc     hl
        ; Sprite Attribute 3
        ; bit 7 = Visible flag (1 = displayed)
        ; bit 6 = Extended attribute (1 = Sprite Attribute 4 is active)
        ; bits 5-0 = Pattern used by sprite (0-63)
        nextreg IO_SpriteAttrib3, a

        ld      a, (hl)
        ; Sprite Attribute 4
        ; bit 7 = H (1 = sprite uses 4-bit patterns)
        ; bit 6 = N6 (0 = use the first 128 bytes of the pattern else use the last 128 bytes)
        ; bit 5 = 1 if relative sprites are composite, 0 if relative sprites are unified
        ; Scaling
        ; bits 4-3 = X scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
        ; bits 2-1 = Y scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
        ; bit 0 = MSB of Y coordinate
        nextreg IO_SpriteAttrib4, a

        ld      a, SIZEOF_sprite-5
        add     hl, a
        jp      nextSprite
  ENDIF
        ;
        ; Make a sprite visible.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
enableSprite:
        push    af
        ld      a, (ix+attrib3)
        or      0x80
        ld      (ix+attrib3), a
        pop     af
        ret

        ;
        ; Make a sprite non-visible.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
disableSprite:
        push    af
        ld      a, (ix+attrib3)
        and     0x7f
        ld      (ix+attrib3), a
        pop     af
        ret

        ;
        ; Send a sprites attributes to the hardware.
        ;
        ; Input:
        ;   xi - Pointer to sprite
        ;
updateSpriteAttribs:
        push    bc
        push    hl

        ld      hl, ix

        ld      bc, 0x303b
        outinb
        ld      bc, 0x0057
        outinb
        outinb
        outinb
        outinb

        pop     hl
        pop     bc
        ret

        ;
        ; Update a sprites X & Y pixel position.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;   b - Sprite Y pixel position
        ;   c - Sprite X pixel position
        ;
setSpriteXY:
        push    af
        push    bc

        ; Set Y position
        ld      a, b
        add     32
        ld      (ix+attrib1), a

        ; Set X position
        ld      a, c
        add     32
        ld      (ix+attrib0), a

        ld      a, (ix+attrib2)
        jr      c, spriteXMSB
        and     0xfe
updateXMSB:
        ld      (ix+attrib2), a

        pop     bc
        pop     af
        ret

spriteXMSB:
        or      0x01
        jr      updateXMSB

        ;
        ; Set a sprites pattern.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;	a  - Pattern index
        ;
setSpritePattern:
        push    af
        push    bc

        ld      b, a
        ld      a, (ix+attrib3)
        and     0xc0
        or      b
        ld      (ix+attrib3), a

        pop     bc
        pop     af
        ret

        ;
        ; Update to the sprites next animation pattern.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
        ; Output:
        ;   a - Current pattern index
        ;
nextSpritePattern:
        push    bc

        ld      a, (ix+endPtn)
        ld      b, (ix+currentPtn)
        inc     b
        cp      b
        call    c, resetSpritePattern

        ld      (ix+currentPtn), b

        ld      a, b
        call    setSpritePattern

        pop     bc
        ret

resetSpritePattern:
        ld      b, (ix+startPtn)
        ret

        ;
        ; Set the state of a sprites horizontal flip bit.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;   a - bit0 = 0, no flip; bit0 = 1, flip
        ;
        ; Output:
        ;   a - Sprite attribute 2
        ;
setSpriteFlip:
        push    bc
        push    af

        ld      a, (ix+attrib2)
        and     0xf7
        ld      b, a

        pop     af
        rlca
        rlca
        rlca
        and     0x08
        or      b
        ld      (ix+attrib2), a

        pop     bc
        ret

        ;
        ; Set the state of a sprites vertical flip bit.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;   a - bit0 = 0, no flip; bit0 = 1, flip
        ;
        ; Output:
        ;   a - Sprite attribute 2
        ;
setSpriteVFlip:
        push    bc
        push    af

        ld      a, (ix+attrib2)
        and     0xfb
        ld      b, a

        pop     af
        rlca
        rlca
        and     0x04
        or      b
        ld      (ix+attrib2), a

        pop     bc
        ret

        ;
        ; Return the state of a sprites horizontal flip bit.
        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
        ; Output:
        ;   a - bit0 = 0, no flip; bit0 = 1, flip
getSpriteFlip:
        ld      a, (ix+attrib2)
        rrca
        rrca
        rrca
        and     0x01
        ret

        ;
        ; Make all sprites in the sprite list non-visible.
        ;
        ; Input:
        ;   None
        ;
disableAllSprites:
        push    af
        push    bc
        push    de
        push    hl

        ld      hl, spriteList
        ld      de, SIZEOF_sprite
        ld      b, +(spriteListEnd-spriteList)/SIZEOF_sprite
disableLoop:
        ld      a, (hl)

        nextreg IO_SpriteNumber, a
        nextreg IO_SpriteAttrib3, 0

        add     hl, de
        djnz    disableLoop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

        section DATA_2
spriteList:
		; Wee Knight
knightSprite:
        db      0x7f
        ds      SIZEOF_sprite-1

        ; Spiders
spiderSprites:
        db      0x01
        ds      SIZEOF_sprite-1
        db      0x02
        ds      SIZEOF_sprite-1
        db      0x03
        ds      SIZEOF_sprite-1
        db      0x04
        ds      SIZEOF_sprite-1
        db      0x05
        ds      SIZEOF_sprite-1
        db      0x06
        ds      SIZEOF_sprite-1
        db      0x07
        ds      SIZEOF_sprite-1
        db      0x08
        ds      SIZEOF_sprite-1
spriteListEnd:
ENDIF
