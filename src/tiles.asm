IF  !_ZXN
        extern  _tile0
        extern  _tileAttr
        extern  setAttr

        public  displayPixelTile
        public  _displayTile
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
        ; Exit:
        ;       b - Y character location
        ;       c - X character location
        ;       a - Tile ID of item
        ;
displayTile:
        push    af
        push    bc
        push    hl

        ; hl = a * 8
        rlca
        rlca
        rlca
        ld      h, a                    ; Save rotated value of A
        and     %11111000               ; Clear out the lower 3 bits
        ld      l, a                    ; and save low order byte

        ld      a, h                    ; Restore the rotated value of A
        and     %00000111               ; Keep lower 3 bits
        ld      h, a                    ; Store the high order byte

        outChar _tile0

        pop     hl
        pop     bc
        pop     af
        ret

        ;
        ; Display the specified tile at the specified pixel location.
        ;
        ; All used registers are preserved by this function.
        ;
        ; Entry:
        ;       b - Y pixel location
        ;       c - X pixel location
        ;       a - Tile ID of item
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
        ld      b, a
        ld      c, -1                   ; Ensure C doesn't wraparound when using ldi

        ; Write the tile data to the screen
        ; de - Pointer to screen
        ; hl - Pointer to tile data
        ; b  - Tile X character offset

        REPT    8
        pop     de                      ; Pop screen address
        ld      a, e                    ; Add X offset
        add     b
        ld      e, a
        ldi
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
        push    af
        push    hl

        ld      hl, _tileAttr
        addhl   a
        ld      a, (hl)

        call    setAttr

        pop     hl
        pop     af
        ret
ENDIF
