
        extern  displayTile
        extern  setTileAttr

        public  displayBanner
        public  bannerData

        include "defs.inc"

        section CODE_2

        defc    BANNER_HEIGHT=0x03

		;
		; Display the in-game banner.
		;
displayBanner:
        push    af
        push    bc
        push    hl

        ld      hl, bannerData
        ld      b, 0                    ; Starting screen Y position
yLoop:
        ld      c, 0                    ; starting screen X position
xLoop:
        ld      a, (hl)                 ; Get the tile ID
        inc     hl                      ; Point to next tile

        call    displayTile
        call    setTileAttr

		; x loop counter
        inc     c
        ld      a, c
        cmp     SCREEN_WIDTH
        jr      nz, xLoop

		; y loop counter
        inc     b
        ld      a, b
        cmp     BANNER_HEIGHT
        jr      nz, yLoop

        pop     hl
        pop     bc
        pop     af
        ret

        section RODATA_2
bannerData:
        include "banner.inc"
