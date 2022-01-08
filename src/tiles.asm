        extern  _tile0
        extern  _tileAttr
        extern  setAttr

IF  !_ZXN
        public  bank7Screen
ENDIF
        public  _displayTile
        public  displayPixelTile
        public  displayTile
        public  setTileAttr

        #include    "defs.inc"

        section CODE_2

        ;
        ; Display the specified tile and attribute at the specified location.
        ;
        ; Callable from 'C' (sccz80)
        ;
        defvars 0                       ; Define the stack variables used
        {
            yPos        ds.b 2
            xPos        ds.b 2
            tile        ds.b 2
        }
_displayTile:
        entry

        ld      b, (ix+yPos)
        ld      c, (ix+xPos)
        ld      a, (ix+tile)

        call    displayTile
        call    setTileAttr

        exit
        ret

IF  !_ZXN
        ;
        ; Display the specified tile at the specified location.
        ;
        ; All used registers are preserved by this function.
        ;
        ; Entry:
        ;		b - Y character location
        ;		c - X character location
        ;		a - Tile ID of item
        ;
displayTile:
        push    af
        push    bc
        push    hl

        ; hl = a * 8
        rlca
        rlca
        rlca
        ld      h, a
        and     %11111000
        ld      l, a

        ld      a, h
        and     %00000111
        ld      h, a

        di
        ; Save the current stack pointer
        ld      (TempSP2+1), sp

        ld      sp, _tile0
        add     hl, sp

        ; Point the stack at the tile data
        ld      sp, hl

        ; Calculate the screen address
        ld      a, b                    ; Y character position
        rrca
        rrca
        rrca
        and     %11100000               ; Bits 5-3 of pixel row
        or      c                       ; X character position
        ld      l, a

        ld      a, b                    ; y character position
        and     %00011000               ; Bits 7-6 of pixel row
bank7Screen:
        or      SCREEN_START>>8         ; 0x40 or 0xc0
        ld      h, a

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        REPT    4
        pop     bc
        ld      (hl), c
        inc     h                       ; Add 256 to screen address
        ld      (hl), b
        inc     h                       ; Add 256 to screen address
        ENDR

        ; Restore the stack pointer.
TempSP2:
        ld      sp, -1
        ei

        pop     hl
        pop     bc
        pop     af
        ret
ELSE
displayTile:
        push    de
        push    hl
        push    af

        ; Multiply Y by 40
        ld      d, b
        ld      e, ZXN_TILEMAP_WIDTH
        mul     d, e

        ; Add the tilemap base address
        ld      hl, TILEMAP_START
        add     hl, de

        ; Add the X offset
        ld      a, c
        add     hl, a
        pop     af

        ; Update tilemap
        ld      (hl), a

        pop     hl
        pop     de
        ret
ENDIF
        ;
        ; Display the specified tile at the specified pixel location.
        ;
        ; All used registers are preserved by this function.
        ;
        ; Entry:
        ;		b - Y pixel location
        ;		c - X pixel location
        ;		a - Tile ID of item
        ;
displayPixelTile:
        push    af
        push    bc
        push    de
        push    hl

        di
        ld      (clearTileSP+1), sp

        calculateRow    b

        ; Calculate the index into the tilesheet
        ; hl = tileID * 8
        rlca
        rlca
        rlca
        ld      h, a
        and     %11111000
        ld      l, a

        ld      a, h
        and     %00000111
        ld      h, a
        ld      de, _tile0
        add     hl, de

        ld      a, c                    ; Item x pixel position to char position
        rrca
        rrca
        rrca
        and     %00011111
        ld      c, a

        ; Write the tile data to the screen
        ; de - Pointer to screen
        ; hl - Pointer to tile data
        ; c  - Tile X character offset

        REPT    8
        pop     de                      ; Pop screen address
        ld      a, e                    ; Add X offset
        add     c
        ld      e, a
        ld      a, (hl)                 ; Move tile data to the screen
        ld      (de), a
        inc     hl
        ENDR

clearTileSP:
        ld      sp, -1
        ei


        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

        ;
        ; Set the attribute for the tile at the specified location
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;		a - Tile ID of item
        ;
setTileAttr:
IF  !_ZXN
        push    af
        push    hl

        ld      hl, _tileAttr
        addhl   a
        ld      a, (hl)

        call    setAttr

        pop     hl
        pop     af
ENDIF
        ret

