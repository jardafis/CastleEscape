        extern  _levels
        extern  _tileMapX
        extern  _xPos
        extern  _yPos
        extern  clearAttr
        extern  displayPixelTile
        extern  displayTile
        extern  displayTile
        extern  setTileAttr

        public  _initItems
        public  checkItemCollision
        public  displayItems
IF  !_ZXN
        public  displayPixelItems
ENDIF
        public  removeItem
        public  setCurrentItemTable

        #include    "defs.inc"

        defc    ITEM_WIDTH=0x08
        defc    ITEM_HEIGHT=0x08

        ;
        ;	Flag bits:
        ;	+---------------+
        ;	|7|6|5|4|3|2|1|0|
        ;	+---------------+
        ;	 | | | | | | | |
        ;	 | | | | | | | +-- Visible
        ;	 | | | | | | +---- Unused
        ;	 | | | | | +------ Unused
        ;	 | | | | +-------- Unused
        ;	 | | | +---------- Unused
        ;	 | | +------------ Unused
        ;	 | +-------------- Unused
        ;	 +---------------- End of table
        ;

        section CODE_2
        ;
        ; Entry:
        ;		hl - Pointer to the item table
        ;		de - Pointer to the item list
        ;		a  - Tile ID of item being initialized
        ;
        ; This routine scans each level from top right to bottom left
        ; building up a table of items for each level. These tables
        ; are then used by animation routines and collision routines.
        ;
        defvars 0                       ; Define the stack variables used
        {
            levelX      ds.b 1
            levelY      ds.b 1
            tileX       ds.b 1
            tileY       ds.b 1
            itemCount   ds.b 1
            SIZEOF_stackVars
        }

_initItems:
        push    af
        push    bc
        push    hl
        push    ix
        push    iy

        ;
        ; Save parameters passed in registers
        ;
        ld      (itemID+1), a
        ld      (currentItemTable), hl

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP+1), sp
        ld      ix, -SIZEOF_stackVars
        add     ix, sp
        ld      sp, ix

        ;
        ; Initialize memory variables
        ;
        ld      (ix+levelY), MAX_LEVEL_Y
        ld      (ix+itemCount), 0

        ld      hl, _levels
levelYLoop:
        ld      (ix+levelX), MAX_LEVEL_X

levelXLoop:
        push    hl
        ld      hl, (currentItemTable)
        ld      (hl), e
        inc     hl
        ld      (hl), d
        inc     hl
        ld      (currentItemTable), hl
        pop     hl

        push    hl                      ; Save level pointer

        ld      (ix+tileY), 3
        ld      c, LEVEL_HEIGHT
tileYLoop:
        ld      (ix+tileX), 0
        ld      b, SCREEN_WIDTH
tileXLoop:
        ld      a, (hl)                 ; Get tile ID
itemID:
        cp      -1
        call    z, addItem
        inc     hl
        inc     (ix+tileX)
        djnz    tileXLoop

        ; Next row in the tilemap
        push    bc
        ld      bc, SCREEN_WIDTH*MAX_LEVEL_X-SCREEN_WIDTH
        add     hl, bc
        pop     bc

        inc     (ix+tileY)
        dec     c
        jr      nz, tileYLoop

        pop     hl                      ; Restore level pointer

        ;
        ; Move the current level pointer to the next level to the right
        ;
        ld      bc, SCREEN_WIDTH
        add     hl, bc

        ; Flags, bit 7, end of list
        ld      a, 0x80
        ld      (de), a
        inc     de

        ;
        ; Decrement X counter and loop if not zero
        ;
        dec     (ix+levelX)
        jr      nz, levelXLoop

        ;
        ; Move the current level pointer to the next level down
        ;
        ld      bc, -SCREEN_WIDTH*MAX_LEVEL_X
        add     hl, bc
        ld      bc, SCREEN_WIDTH*MAX_LEVEL_X*LEVEL_HEIGHT
        add     hl, bc

        ;
        ; Decrement Y counter and loop if not zero
        ;
        dec     (ix+levelY)
        jr      nz, levelYLoop

        ;
        ; Restore the stack frame
        ;
tempSP:
        ld      sp, -1

        pop     iy
        pop     ix
        pop     hl
        pop     bc
        pop     af
        ret

        ;
        ; Add a coin to the coin table
        ;
addItem:
        ; Flags, Bit0 = visible
        ld      a, 1
        ld      (de), a
        inc     de

        ; X screen position
        ld      a, (ix+tileX)
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        ld      (de), a
        inc     de

        ; Y screen position
        ld      a, (ix+tileY)
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        ld      (de), a
        inc     de

        ; Animation frame
        ld      a, (ix+itemCount)
        inc     (ix+itemCount)
        ld      (de), a
        inc     de

        ret

        ;
        ; Calculate the value of the current item table based
        ; on the values of tileMapX and tileMapY and save it
        ; to the memory location pointed to by 'hl'.
        ;
        ; Entry:
        ;		hl - Pointer to current item table variable
        ; 		de - Pointer to item tables
        ;
setCurrentItemTable:
        ld      (currItemTab+2), hl
        ld      hl, (_tileMapX)         ; Get tileMapX & tileMapY
        ld      a, h
        ax      MAX_LEVEL_X*SIZEOF_ptr
        ld      h, a
        ld      a, l
        ax      SIZEOF_ptr
        add     h
        ld      l, a
        ld      h, 0
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
currItemTab:
        ld      (-1), de
        ret

        ;
        ; Display the visible items pointed to by hl. Typically
        ; called when the level changes to display the items
        ; which have not yet been collected or to display items
        ; in their new position if they are moving.
        ;
        ; Entry:
        ;		hl - Pointer to item table
        ;		a  - Tile ID of item
        ;
displayItems:
        ld      d, a                    ; Save tile ID
nextItem2:
        ld      a, (hl)                 ; Flags
        or      a
        ret     m
        jr      z, notVisible2

        inc     hl
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl

        pixelToChar b, c

        inc     hl                      ; Skip animation frame
        ld      a, d                    ; Tile ID
        call    displayTile             ; Display tile
        call    setTileAttr
        jr      nextItem2

notVisible2:
        addhl   SIZEOF_item
        jr      nextItem2

IF  !_ZXN
        ;
        ; Display the visible pixel aligned items pointed to by hl.
        ;
        ; Entry:
        ;		hl - Pointer to item table
        ;		a  - Tile ID
        ;
displayPixelItems:
        ld      d, a                    ; Save tile ID
nextItem5:
        ld      a, (hl)                 ; Flags
        or      a
        ret     m
        jr      z, notVisible5

        inc     hl
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl

        inc     hl                      ; Skip animation frame

        ld      a, d                    ; Tile ID
        call    displayPixelTile        ; Display tile
        jr      nextItem5

notVisible5:
        addhl   SIZEOF_item
        jr      nextItem5
ENDIF
        ;
        ; Check if the player has collided with an item. And if so,
        ; remove the item and attrinute from the level and call
        ; the user provided sub-routine to update socres, etc.
        ;
        ;	Entry:
        ;		hl - Pointer to current item table
        ;		de - Pointer to subroutine to call when collision is detected
        ;
checkItemCollision:
        ld      (itemCollision+1), de
nextItem:
        ld      a, (hl)
        or      a
        ret     m
        jr      z, notVisible3

        push    hl
        inc     hl

        ;
        ; Collision check here
        ;
        ld      a, (hl)                 ; X byte position

        add     2                       ; Left side pixel offset (indented a little)
        ld      b, a
        add     ITEM_WIDTH-5            ; Right side pixel offset (pulled in a little)
        ld      c, a

        ld      a, (_xPos)              ; Player left side pixel position
        inc     a
        cp      c                       ; Compare with coin right side
        jr      nc, noCollision         ; 'nc' if 'c' <= 'a'

        add     PLAYER_WIDTH-4          ; Get right side pixel position
        cp      b                       ; Compare with coin left side
        jr      c, noCollision          ; 'c' if 'b' > 'a'

        inc     hl
        ld      a, (hl)                 ; Y byte position

        add     2                       ; Top pixel offset pulled in a little
        ld      b, a
        add     ITEM_HEIGHT-5           ; Bottom pixel offset, pushed up a little
        ld      c, a

        ld      de, (_yPos)
        fix_to_int  d, e
        cp      c                       ; Compare with bottom
        jr      nc, noCollision         ; 'nc' if 'c' <= 'a'

        add     PLAYER_HEIGHT-1         ; Player bottom pixel position
        cp      b                       ; Compare with top
        jr      c, noCollision          ; 'c' if 'b' > 'a'

        ld      b, (hl)                 ; Y position
        srl     b
        srl     b
        srl     b
        dec     hl                      ; Back to the flags
        ld      c, (hl)                 ; X position
        srl     c
        srl     c
        srl     c
        dec     hl                      ; hl points to item flags

        ;
        ; User provided function to update score, etc.
        ;
itemCollision:
        call    -1
noCollision:
        pop     hl
notVisible3:
        addhl   SIZEOF_item
        jp      nextItem

        ;
        ; Remove an item from the screen and change
        ; it's flags so that it is no longer visible.
        ;
        ;	Entry:
        ;		hl - Pointer to items flags
        ;		b  - Screen y character position
        ;		c  - screen x character position
        ;
removeItem:
        ld      (hl), 0                 ; Zero flags and save in item table
        call    clearAttr               ; Remove the item and attribute
        ld      a, ID_BLANK
        call    displayTile
        ret

        section BSS_2
currentItemTable:
        ds      2


