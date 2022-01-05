IF  _ZXN

        extern  tile_palette_end
        extern  tile_palette
        extern  spriteStart
        extern  spriteEnd
        extern  spritePalette
        extern  spritePaletteEnd

        public  zxnInit
        public  clearTilemap
        public  clearULACoin
        public  clearULACoinHi
        public  clearULATile
        public  clearULATilePixel
        public  enableSprite
        public  disableSprite
        public  setSpriteXY
        public  spriteList
        public  setSpritePattern

        #include    "defs.inc"

        section CODE_2
zxnInit:
        call    initTilemap

		; Bank 4 contains sprite data
        bank    4
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

        bank    0

        call    setupSprites

        ret

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

clearTilemap:
        ; Clear the tilemap area
        ld      hl, tilemapAddr
        ld      (hl), ID_BLANK          ; Tile ID
        ld      de, tilemapAddr+1
        ld      bc, tilemapSize-1
        ldir
        ret

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
        ; Input:
        ;   e - X pixel coord.
        ;   d - Y pixel coord.
        ;
clearULATilePixel:
        push    bc
        push    hl

        pixelad

        ld      a, h
bank7:
        or      0x00
        ld      h, a


        ld      b, 8
clrULATileLoop:
        ld      (hl), 0
        inc     h
        djnz    clrULATileLoop

        pop     hl
        pop     bc
        ret

        ; Input:
        ;   hl - Pointer to coin table
        ;
clearULACoinHi:
        ld      a, 0x80
        ld      (bank7+1), a
        call    clearULACoin
        xor     a
        ld      (bank7+1), a
        ret

        ; Input:
        ;   hl - Pointer to coin table
        ;
clearULACoin:
        ld      a, (hl)
        cp      0xff
        ret     z

        inc     hl
        ld      e, (hl)
        inc     hl
        ld      d, (hl)

        call    clearULATilePixel

        add     hl, 2
        jp      clearULACoin


initTilemap:
        call    clearTilemap

        ; Set the tilemap base address
        nextreg IO_TileMapBaseAdrr, tilemapAddr>>8

        ; Set the tile definition base address
        nextreg IO_TileMapDefBaseAddr, tileDefAddr>>8

;*___________________________________________________________________________________________________________________________________

        ; TILE MAP CONTROL
        ; bit 7    = 1 to enable the tilemap
        ; bit 6    = 0 for 40x32, 1 for 80x32
        ; bit 5    = 1 to eliminate the attribute entry in the tilemap
        ; bit 4    = palette select
        ; bits 3-2 = Reserved set to 0
        ; bit 1    = 1 to activate 512 tile mode
        ; bit 0    = 1 to force tilemap on top of ULA

        nextreg IO_TileMapContr, %10100000
                                        ; tile map with  attribute byte eliminated is selected, (bit 5 is 1)

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
        ld      b, tile_palette_end-tile_palette
                                        ; Number of colors
        ld      hl, tile_palette        ; Pointer to palette
        call    setPalette              ; Do it!

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
        ; Input:
        ;   hl - Pointer to sprite pattern data
        ;   bc - Length, in bytes, of sprite pattern data
        ;
initSpritePatterns:
        ld      a, b
        or      a
        jr      z, lastBlock

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
        ret     z

        ld      c, IO_SpritePattern     ; copy sprite data to through register 0x5B
        ld      b, a
        otir                            ; send that

        ret

        ; Input:
        ;       None
        ;
        ; Output:
        ;       a, hl - Corrupt
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

        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
        ; Output:
        ;   a - corrupt.
enableSprite:
        ld      a, (ix+0)
        nextreg IO_SpriteNumber, a

        ld      a, (ix+attrib3)
        or      0x80
        ld      (ix+attrib3), a

        nextreg IO_SpriteAttrib3, a
        ret

        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
        ; Output:
        ;   a - corrupt.
disableSprite:
        ld      a, (ix+0)
        nextreg IO_SpriteNumber, a

        ld      a, (ix+attrib3)
        and     0x7f
        ld      (ix+attrib3), a

        nextreg IO_SpriteAttrib3, a
        ret

        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;
        ; Output:
        ;   a - corrupt.
setSpriteXY:
        ld      a, (ix+0)
        nextreg IO_SpriteNumber, a

        ; Set Y position
        ld      a, h
        ld      (ix+attrib1), a
        add     32
        nextreg IO_SpriteAttrib1, a

        ; Set X position
        ld      a, l
        ld      (ix+attrib0), a
        add     32
        nextreg IO_SpriteAttrib0, a

        ld      a, (ix+attrib2)
        jr      c, spriteXMSB
        and     0xfe
updateXMSB:
        ld      (ix+attrib2), a
        nextreg IO_SpriteAttrib2, a
        ret

spriteXMSB:
        or      0x01
        jr      updateXMSB

        ;
        ; Input:
        ;   ix - Pointer to sprite
        ;	a  - Pattern ID
        ;
        ; Output:
        ;   a - corrupt.
setSpritePattern:
        push    bc

        ld      b, a

        ld      a, (ix+0)
        nextreg IO_SpriteNumber, a

        ld      a, (ix+attrib3)
        and     0xc0
        or      b
        ld      (ix+attrib3), a

        nextreg IO_SpriteAttrib3, a

        pop     bc
        ret

        section DATA_2
spriteList:
        db      0x00                    ; Sprite index
        db      50                      ; X (Attrib 0)
        db      24*8                    ; Y (Attrib 1)
        db      0x00                    ; Attribute 2
        db      0x40                    ; Attribute 3
        db      0x00                    ; Attribute 4
        db      0                       ; Animation frame count
        db      0                       ; Current frame count
        db      0                       ; Start pattern
        db      4                       ; End pattern
        db      0                       ; Current pattern

        db      0x01                    ; Sprite index
        db      100                     ; X
        db      24*8                    ; Y
        db      0x00                    ; Attribute 2
        db      0x40                    ; Attribute 3
        db      0x00                    ; Attribute 4
        db      25                      ; Animation frame count
        db      25                      ; Current frame count
        db      0                       ; Start pattern
        db      4                       ; End pattern
        db      0                       ; Current pattern

        db      0x80                    ; End of sprite list

ENDIF
