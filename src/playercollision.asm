        extern  _currentTileMap
        extern  _falling
        extern  _jumping
        extern  _setupScreen
        extern  _tileMapX
        extern  _tileMapY
        extern  _xPos
        extern  _xSpeed
        extern  _yPos
        extern  _ySpeed
        extern  die
        extern  wyz_play_sound

        public  checkXCol
        public  checkYCol

        #include    "defs.inc"
        section CODE_2

        defc    ID_SOLID_TILE=12*TILE_SHEET_WIDTH
        defc    ID_SOFT_TILE=10*TILE_SHEET_WIDTH
        defc    FALL_DISTANCE=33
        defc    SCREEN_OFFSET=24

        ;
        ; Check for player colliding with platforms on
        ; the X axis and if the player is going off the screen
        ; to the left or right display the next or previous
        ; level.
        ;
        ; Entry:
        ;		a - xSpeed
        ;
        ; Register variables:
        ;		b - xSpeed
        ;		c - yPos
        ;
checkXCol:
        ; Save the xSpeed, this will be added to xPos
        ; if there is no collision before this routine
        ; exits.
        ld      b, a
        ; Get the X pixel offset and put it in DE.
        ; It needs to be 16 bits so when we
        ; add the PLAYER_WIDTH it doesn't overflow.
        ld      a, (_xPos)
        ld      e, a
        ld      d, 0

        ; Flags were updated based on xSpeed before
        ; this routine was called. Positive = right,
        ; negative = left.
        jp      p, movingRight
        ; We are checking the new position, which is 1 pixel
        ; to the left.
        inc     de
        inc     de
        inc     de
        jr      movingLeft
movingRight:
        ; Player is moving right, check the new position,
        ; which is 1 pixel to the right of the player.
        addde   PLAYER_WIDTH-4
movingLeft:
        ; Get the yPos into HL. It needs to be 16
        ; bits as we will convert it to a Y offset
        ; within the tilemap.
        ld      hl, (_yPos)
        fix_to_int  h, l
        ; Subtract the delta between the screen offset and the level offset.
        ; Since the first 3 character rows of the screen is status info we
        ; should remove them.
        ld      a, -SCREEN_OFFSET
        add     l
        ; Save the result in C
        ld      c, a
        ; Remove the pixel offset within the byte (lower 3 bits)
        and     %11111000
        ld      l, a
        ; Divide by 8 to get byte offset and multiply by width of tilemap
        hlx     TILEMAP_WIDTH/8

        ; Divide xPos by 8 to get byte offset
        ; This code is 44 cycles vs. using
        ; srl d, rr, e which is 48 cycles
        ld      a, e
        sra     d
        rra
        sra     d
        rra
        sra     d
        rra
        ld      e, a
        ; Add X byte offset to tile map Y index
        add     hl, de

        ; Add the base address of the currently
        ; displayed tilemap.
        ld      de, (_currentTileMap)
        add     hl, de

        ; Get the tile to the left or right of the
        ; top half of the player sprite.
        ld      a, (hl)
        cp      ID_SOLID_TILE
        ; If the tile is solid, cannot continue in this
        ; direction, exit now.
        jr      nc, stopX               ; 'nc' if a >= ID_SOLID_TILE

        ; Check the bottom half of the sprite.
        ; Add the tilemap width to get the next row
        ; down.
        ld      de, TILEMAP_WIDTH
        add     hl, de

        ld      a, (hl)
        cp      ID_SOLID_TILE
        jr      nc, stopX               ; 'nc' if a >= ID_SOLID_TILE

        ; If the player is in the middle of a jump,
        ; it may span 3 characters rather than 2.
        ; If the yPos is not character aligned check
        ; the next row down in the tilemap.
        ld      a, c                    ; Restore yPos
        and     %00000111               ; If the lower 3 bits are zero player has not shifted into
        jr      z, checkXDone           ; the next row down, we are done.
        add     hl, de                  ; Next row down

        ld      a, (hl)
        cp      ID_SOLID_TILE
        jr      nc, stopX               ; 'nc' if a >= ID_SOLID_TILE

checkXDone:
        ld      a, (_xPos)              ; Get the X pixel offset
        add     b                       ; Add speed
        cp      -1                      ; If new xPos is -1
        jr      z, previousXLevel       ; display previous level.
        cp      MAX_X_POS-PLAYER_WIDTH+1
        jr      nc, nextXLevel          ; 'nc' if a >= value
        ld      (_xPos), a
        ret

previousXLevel:
        ld      a, (_tileMapX)
        or      a
        ret     z
        dec     a
        ld      (_tileMapX), a

        ; New x position
        ld      a, MAX_X_POS-PLAYER_WIDTH
        jr      changeXLevel
nextXLevel:
        ld      a, (_tileMapX)
        cp      MAX_LEVEL_X-1
        ret     z
        inc     a
        ld      (_tileMapX), a

        ; New x position
        xor     a
changeXLevel:
        ld      (_xPos), a
        call    _setupScreen
        ret
stopX:
        xor     a
        ld      (_xSpeed), a
        ret

        ;
        ; Check for player colliding with platforms on
        ; the Y axis and if the player is going off the screen
        ; to the top or bottom display the next or previous
        ; level.
        ;
        ; Entry:
        ;		None
        ;
        ; Register variables:
        ;		b - ySpeed sign bit
        ;		c - _xPos
        ;
checkYCol:
        ld      hl, (_ySpeed)
        ld      b, h                    ; Save sign bit for later
        ld      a, h
        or      a
        jp      m, movingUp
movingDown:
        ; Pixel position of the players feet
        ld      de, FIX_POINT(PLAYER_HEIGHT-1-SCREEN_OFFSET, 0)

        ld      a, (_jumping)
        or      a
        jr      nz, _l_1
        ld      hl, GRAVITY
        ld      (_ySpeed), hl
        ld      b, h                    ; Save sign bit for later
        jr      _l_1
movingUp:
        ld      de, FIX_POINT(-SCREEN_OFFSET, 0)
_l_1:
        add     hl, de
        ld      de, (_yPos)
        add     hl, de

        fix_to_int  h, l

        ;
        ; Divide hl by 8 to remove the pixel offset.
        ; It could be negative at this point.
        ;
        sra     h
        rra
        sra     h
        rra
        sra     h
        rra
        ld      l, a
        ;
        ; Multiply by TILEMAP_WIDTH
        ;
        hlx     TILEMAP_WIDTH

        ld      a, (_xPos)              ; Get the X pixel offset
        add     4
        ld      c, a                    ; Save pixel offset for later
        rrca                            ; Divide by 8 to get the byte offset
        rrca                            ; Faster to do rrca followed by AND rather than srl
        rrca
        and     %00011111
        addhl   a                       ; Add X byte offset to tile map Y index

        ld      de, (_currentTileMap)
        add     hl, de

        ld      d, ID_SOLID_TILE        ; Default to ID_SOLID_TILE
        ld      a, b
        or      a
        jp      m, checkSolids          ; Player is moving upward, only check solid tiles

        ; Player is moving downward, include soft tiles
        ; only if the Y position is tile aligned
        push    hl
        ld      hl, (_yPos)
        fix_to_int  h, l
        pop     hl
        and     0x07
        jr      nz, checkSolids

        ld      d, ID_SOFT_TILE         ; Switch to ID_SOFT_TILE
checkSolids:

        ld      a, (hl)                 ; Get tile ID
        cp      d
        jr      nc, yCollision          ; 'nc' if a >= value

        ld      a, c                    ; Restore X pixel offset
        and     %00000111               ; Check if any of the lower 3 bits are set
        jr      z, noYCollision         ; if not we are done

        inc     hl                      ; Check the tile to the right
        ld      a, (hl)
        cp      d
        jr      nc, yCollision          ; 'nc' if a >= value

noYCollision:
        ld      a, (_jumping)           ; Check if player jumping
        or      a
        jr      nz, updateYPos

        ;
        ; Transition to falling.
        ;  Clear X movement.
        ;  Increment the falling counter.
        xor     a
        ld      (_xSpeed), a
        ld      hl, _falling
        inc     (hl)
        ld      a, FALL_DISTANCE        ; Distance before falling starts
        cp      (hl)
        push    bc
        di
        ld      a, AYFX_FALLING
        ld      b, AYFX_CHANNEL
        call    z, wyz_play_sound
        ei
        pop     bc

updateYPos:
        ;
        ; Update y position
        ;
        ld      hl, (_yPos)
        ld      de, (_ySpeed)
        add     hl, de

        fix_to_int  h, l

        cp      MAX_Y_POS-PLAYER_HEIGHT
        jr      nc, nextYLevel          ; 'nc' if a >= value
        cp      SCREEN_OFFSET
        jr      c, previousYLevel       ; 'c' if 'a' < value

        ld      hl, (_yPos)
        add     hl, de
        ld      (_yPos), hl
        ret

previousYLevel:
        ld      a, (_tileMapY)
        or      a
        ret     z
        dec     a
        ld      (_tileMapY), a
        ld      hl, FIX_POINT(MAX_Y_POS-PLAYER_HEIGHT, 0)
        jr      changeYLevel
nextYLevel:
        ld      a, (_tileMapY)
        cp      MAX_LEVEL_Y-1
        ret     z
        inc     a
        ld      (_tileMapY), a
        ld      hl, FIX_POINT(SCREEN_OFFSET, 0)
changeYLevel:
        ld      (_yPos), hl
        call    _setupScreen
        ret

yCollision:
	    ;
	    ; If player was moving down, stop moving
	    ;
        ld      a, b
        or      a
        jp      p, landed

	    ;
	    ; Player is going up check for ID_SOFT_TILE
	    ;
        ld      a, d
        cp      ID_SOFT_TILE
        jr      z, noYCollision
        ;
        ; Collided with ID_SOLID_TILE going up
        ; Don't update yPos.
        ;
        ret

landed:
        ;
        ; Reset ySpeed, jumping count and falling flag
        ;
        ld      a, (_falling)
        cp      FALL_DISTANCE
        call    nc, die

        xor     a
        ld      (_ySpeed), a
        ld      (_ySpeed+1), a
        ld      (_jumping), a
        ld      (_falling), a
        ld      a, (_yPos)
        and     FIX_POINT_MASK
        ld      (_yPos), a
        ret
