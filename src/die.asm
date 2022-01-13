        extern  _falling
        extern  _jumping
        extern  _pasteScreen
        extern  _copyScreen
        extern  _spriteBuffer
        extern  _xPos
        extern  _ySpeed
        extern  decBCD
        extern  display2BCD
IF  !_ZXN
        extern  displayPixelTile
        extern  lastDirection
ELSE
        extern  setSpritePattern
        extern  knightSprite
        extern  updateSpriteAttribs
        extern  setSpriteFlip
ENDIF
        extern  gameOver
        extern  heartCount
        extern  playerSprite
        extern  startSprite
        extern  wyz_play_song
        extern  wyz_player_stop
        extern  xyPos
        extern  xyStartPos

        public  die

        #include    "defs.inc"

        section CODE_2

        ;
        ; Routine called when plater dies.
        ;
die:
        push    af
        push    bc
        push    de
        push    hl

IF  !_ZXN
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _copyScreen

		;
		; Display headstone where player died
		;
        ld      bc, (_xPos)
        ld      a, 12
        call    displayPixelTile
        ld      a, c
        add     8
        ld      c, a
        ld      a, 13
        call    displayPixelTile
        ld      a, b
        add     8
        ld      b, a
        ld      a, 13+16
        call    displayPixelTile
        ld      a, c
        sub     8
        ld      c, a
        ld      a, 12+16
        call    displayPixelTile
ELSE
        ld      ix, knightSprite

        xor     a
        call    setSpriteFlip

        ld      a, SPRITE_ID_TOMBSTONE
        call    setSpritePattern

        call    updateSpriteAttribs
ENDIF
        ;
        ; Stop in-game music and
        ; start the death march
        ;
        di
        call    wyz_player_stop
        ld      a, DEATH_MARCH
        call    wyz_play_song
        ei

        ;
        ; Delay for 200 1/50's of a second (4 seconds) and flash
        ; the border while the music plays.
        ;
        ld      b, 200
delayLoop:
        ld      a, b
        and     0x07
        border  a
        halt
        djnz    delayLoop
        ;
        ; Ensure border is black
        ;
        border  INK_BLACK

        ;
        ; Decrement the heart count
        ;
        ld      de, heartCount
        call    decBCD
        ld      bc, 0x011d              ; y,x screen location
        ex      de, hl
        call    display2BCD

        ;
        ; If the heart count is zero, game over!
        ; hl points to heartCount
        ;
        ld      a, (hl)
        or      a
        jp      z, gameOver

		; Restart in-game music
        ld      a, MAIN_MENU_MUSIC
        di
        call    wyz_play_song
        ei

IF  !_ZXN
        ;
        ; Remove the headstone
        ;
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _pasteScreen
ENDIF

        ; Set player X/Y position (and sprite direction) to where
        ; they entered the level.
        ld      hl, (xyStartPos)
        ld      (xyPos), hl
        ld      hl, (startSprite)
        ld      (playerSprite), hl
        xor     a
        ld      (_jumping), a
        ld      (_ySpeed), a
        ld      (_falling), a
IF  !_ZXN
        ld      (lastDirection), a
ENDIF
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret
