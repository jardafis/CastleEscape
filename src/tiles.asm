        extern  _tile0
        extern  setAttr
        extern  _tileAttr

        public  _displayTile
        public  displayTilePixel
        public  displayTile
        public  bank7Screen
        public  setTileAttr

        include "defs.inc"

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
        ; This subroutine takes the X/Y position as pixel positions
        ; and converts them to character positions. Used for displaying
        ; items which are character aligned.
        ;
        ; Entry:
        ;		b - Y pixel location
        ;		c - X pixel location
        ;		a - Tile ID of item
        ;
displayTilePixel:
        push    af
        ld      a, b                    ; Y char position
        rrca                            ; Divide by 8
        rrca
        rrca
        and     %00011111
        ld      b, a

        ld      a, c                    ; X char position
        rrca                            ; Divide by 8
        rrca
        rrca
        and     %00011111
        ld      c, a
        pop     af

		; *********************************************
		; FALL THROUGH TO DISPLAY THE TILE
		; DO NOT INSERT CODE BETWEEN THESE FUNCTIONS
		; *********************************************

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
        pop     bc
        ld      (hl), c
        inc     h                       ; Add 256 to screen address
        ld      (hl), b
        inc     h                       ; Add 256 to screen address

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b

        ; Restore the stack pointer.
TempSP2:
        ld      sp, -1
        ei

        pop     hl
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
        addhl
        ld      a, (hl)

        call    setAttr

        pop     hl
        pop     af
        ret

