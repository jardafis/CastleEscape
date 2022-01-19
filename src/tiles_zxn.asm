IF  _ZXN
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

        exit
        ret

        ;
        ; Display the specified tile at the specified location.
        ;
        ; All used registers are preserved by this function.
        ;
        ; Entry:
        ;       b - Y character location
        ;       c - X character location
        ;       a - Tile ID of item
        ;
displayTile:
        push    de
        push    hl

        ; Multiply Y by 40
        ld      d, b
        ld      e, ZXN_TILEMAP_WIDTH
        mul     d, e

        ; Add the tilemap base address
        ld      hl, TILEMAP_START
        add     hl, de

        ld      e, a
        ; Add the X offset
        ld      a, c
        add     hl, a

        ; Update tilemap
        ld      (hl), e

        pop     hl
        pop     de
        ret

        ;
        ; Set the attribute for the tile at the specified location
        ;
        ; Entry:
        ;       b - Y location
        ;       c - X location
        ;       a - Tile ID of item
        ;
setTileAttr:
        ret
ENDIF
