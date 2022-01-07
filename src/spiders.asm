        extern  _currentTileMap
        extern  die
        extern  displayPixelTile
        extern  rand
        extern  ticks

        public  currentSpiderTable
        public  displaySpiders
        public  spiderCollision
        public  spiderTables
        public  updateSpiderPos
IF  _ZXN
        public  initSpiders
        extern  spiderSprites
        extern  setSpritePattern
        extern  setSpriteXY
        extern  enableSprite
        extern  disableSprite
        extern  updateSpriteAttribs
        extern  setSpriteVFlip
ENDIF

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

        #include    "defs.inc"

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
        and     ~(UP<<1|DOWN<<1)        ; into the item flags
        or      b                       ; and save the flags.
        ld      (hl), a

        ld      de, SIZEOF_item
        add     hl, de
        jr      nextSpider

update:
        ld      a, (ticks)
        rrca
        ret     c
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
        ; Display the spiders from the current spider table.
        ;
displaySpiders:
        ld      hl, (currentSpiderTable)
IF  _ZXN
        ld      ix, spiderSprites
ENDIF
nextItem:
        ld      a, (hl)                 ; Flags
        or      a
        ret     m
        inc     hl

        ld      c, (hl)                 ; X pixel position
        inc     hl
        ld      b, (hl)                 ; Y pixel position
        inc     hl

        inc     hl                      ; Skip animation frame

IF  !_ZXN
        ld      a, b                    ; Determine the animation from the Y pixel position
        and     %00000001
        add     ID_SPIDER

        call    displayPixelTile        ; Display tile
ELSE
        and     UP<<1|DOWN<<1           ; Up/Down bits
        jr      z, noChange

        ; Default to pattern ID for upward spider
        ld      d, SPRITE_ID_SPIDER_UP

        ; Check for spider moving down
        and     DOWN<<1
        jr      z, movingUp

        ; Set pattern ID for downward spider
        ld      d, SPRITE_ID_SPIDER_DOWN
movingUp:
        call    setSpriteXY

        ld      a, b
        and     0x01
        add     d
        call    setSpritePattern

        call    updateSpriteAttribs

noChange:
        ; Point to next sprite
        ld      de, SIZEOF_sprite
        add     ix, de
ENDIF
        jp      nextItem

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

IF  _ZXN
initSpiders:
        ld      ix, spiderSprites
        ld      b, MAX_SPIDERS
disableAllSpiders:
        call    disableSprite
        call    updateSpriteAttribs

        ; Point to next sprite
        ld      de, SIZEOF_sprite
        add     ix, de

        djnz    disableAllSpiders

        ld      ix, spiderSprites
        ld      hl, (currentSpiderTable)
nextSpiderSprite:
        ld      a, (hl)
        or      a
        ret     m
        inc     hl
        call    enableSprite

        ; Spider X
        ld      c, (hl)
        inc     hl
        ; Spider Y
        ld      b, (hl)
        inc     hl
        inc     hl

        call    setSpriteXY

        ld      a, b
        and     0x01
        add     SPRITE_ID_SPIDER_UP
        call    setSpritePattern

        call    updateSpriteAttribs

        ; Point to next sprite
        ld      de, SIZEOF_sprite
        add     ix, de

        jr      nextSpiderSprite
ENDIF

        section DATA_2

changeSpiderDir:
        db      25

        section BSS_2

currentSpiderTable:
        ds      2

spiderTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

