        extern  _lanternList
        extern  displayTile
        extern  setTileAttr

        public  displayTileMap

        include "defs.inc"

        section CODE_2
        ;
        ; Display a tilemap
        ;
        ; Entry:
        ;	hl - Pointer to the tilemap to display
        ;
displayTileMap:
        push    af
        push    bc
        push    de
        push    hl

        ld      de, _lanternList        ; Zero the lantern count
        xor     a                       ; for this level
        ld      (de), a

        inc     de                      ; Point to first address in table
        ld      (lanternPtr+1), de      ; Initialize lantern table pointer

        halt

        ld      b, 3                    ; Start screen Y character position
yloop:
        ld      c, 0                    ; Start screen X character position
xloop:
        ld      a, (hl)                 ; read the tile index
        cmp     ID_BLANK                ; Check for blank
        jr      z, nextTile             ; On to the next tile

        ;
        ; Don't display collectible or moving items.
        ;
        cmp     ID_COIN
        jr      z, nextTile
        cmp     ID_EGG
        jr      z, nextTile
        cmp     ID_HEART
        jr      z, nextTile
        cmp     ID_SPIDER
        jr      z, nextTile

        ;
        ; Check for lanterns and add them to the lanter table for this level
        ;
        cmp     ID_LANTERN
        call    z, addLantern

        call    displayTile
        call    setTileAttr

nextTile:
        inc     hl                      ; next tile

        inc     c
        ld      a, c
        cmp     SCREEN_WIDTH
        jr      nz, xloop

        ld      de, TILEMAP_WIDTH-SCREEN_WIDTH
        add     hl, de

        inc     b
        ld      a, b
        cmp     LEVEL_HEIGHT+3          ; Level height + screen offset
        jr      nz, yloop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

        ;
        ; Calculate the screen attribute address of the lantern and save it
        ; to the lantern table for this level.
        ;
        ; Entry:
        ;	b - Lantern Y screen position
        ;	c - Lantern X screen position
        ;
addLantern:
        push    af
        push    hl

        ; Increment the lantern count
        ld      hl, _lanternList
        inc     (hl)

        ; Calculate the screen attribute address
        ld      a, b
        rrca
        rrca
        rrca
        ld      h, a
        and     %11100000
        or      c
        ld      l, a

        ld      a, h
        and     %00000011
        or      SCREEN_ATTR_START>>8
        ld      h, a
lanternPtr:
        ld      (-1), hl                ; Self modifying code. Store screen address in table

        ld      hl, lanternPtr+1        ; Increment table pointer
        inc     (hl)
        inc     (hl)

        pop     hl
        pop     af
        ret
