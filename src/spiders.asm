        extern  die
        extern  rand
        extern  _currentTileMap

        public  spiderCollision
        public  spiderTables
        public  spiders
        public  currentSpiderTable
        public  updateSpiderPos

		;
		;	Flag bits:
		;	+---------------+
		;	|7|6|5|4|3|2|1|0|
		;	+---------------+
		;	 | | | | | | | |
		;	 | | | | | | | +-- Visible
		;	 | | | | | | +---- Unused
		;	 | | | | | +------ Unused
		;	 | | | | +-------- Down
		;	 | | | +---------- Up
		;	 | | +------------ Unused
		;	 | +-------------- Unused
		;	 +---------------- End of table
		;

        include "defs.inc"

        section CODE_2

updateSpiderPos:
        ld      hl, changeSpiderDir
        dec     (hl)
        jr      nz, update
        ld      (hl), 25

        ld      hl, (currentSpiderTable)
nextSpider:
        ld      a, (hl)                 ; Flags
        or      a
        ret     m

        push    hl

        call    rand
        ld      a, l

        cp      110
        jr      nc, down
		; a >= val
        ld      b, UP<<1
        jr      done
down:
        cp      220
        jr      nc, stop
		; a >= val
        ld      b, DOWN<<1
        jr      done
stop:
		; a < val
        ld      b, 0
done:
        pop     hl

        ld      a, (hl)                 ; OR the direction bits
        and     %00001111               ; into the item flags
        or      b                       ; and save the flags.
        ld      (hl), a

        ld      de, SIZEOF_item
        add     hl, de
        jr      nextSpider

update:
        ld      hl, (currentSpiderTable)
updatePosition:
        ld      a, (hl)                 ; Flags
        or      a
        ret     m                       ; Check for end of list return if true.

        push    hl                      ; Save item pointer

        inc     hl                      ; Skip flags
        ld      c, (hl)                 ; Get x position
        inc     hl
        ld      b, (hl)                 ; Get y position

        bit     UP_BIT+1, a
        jr      z, down2
        ld      a, 24                   ; If the spider is at the top
        cp      b                       ; of the screen it can't move
        jr      z, collision            ; up any more, same as a collision.

        ld      a, -1-24
        add     b

        call    checkCollision
        jr      nz, collision

        ld      a, -1
        jr      done2
down2:
        bit     DOWN_BIT+1, a
        jr      z, stop2
        ld      a, MAX_Y_POS-8          ; IF the spider is at the bottom
        cp      b                       ; of the screen it can't move
        jr      z, collision            ; treat same as collision.

        ld      a, 8-24
        add     b

        call    checkCollision
        jr      nz, collision

        ld      a, 1
        jr      done2
stop2:
        ld      a, 0
done2:
        add     (hl)                    ; move
        ld      (hl), a                 ; Store y position
collision:
        pop     hl
        ld      de, SIZEOF_item
        add     hl, de
        jr      updatePosition

		;
		; Check if a spider has collided with a tile.
		;
		; Entry:
		;		a - Spider y pixel position
		;		c - Spider x pixel position
		;
		; Exit:
		;		nz - Collision detected.
		;
checkCollision:
        push    hl
        srl     c
        srl     c
        srl     c

        rrca
        rrca
        rrca
        and     %00011111

        ld      l, a
        ld      h, 0
		;
		; Multiply by TILEMAP_WIDTH
		;
        hlx     TILEMAP_WIDTH
        ld      de, (_currentTileMap)
        add     hl, de
        ld      b, 0
        add     hl, bc                  ; Add the X character offset

        ld      a, (hl)                 ; Read tile ID
        cp      ID_BLANK                ; If it's blank, there is no collision
        jr      z, noCollision
        cp      ID_SPIDER               ; IF not blank is it a spider?
noCollision:
        pop     hl
        ret

spiderCollision:
        call    die
        ret

        section DATA_2

changeSpiderDir:
        db      25

        section BSS_2

currentSpiderTable:
        ds      2

spiderTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

spiders:
        ds      SIZEOF_item*MAX_SPIDERS*MAX_LEVEL_X*MAX_LEVEL_Y
