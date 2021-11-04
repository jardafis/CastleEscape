        extern  _falling
        extern  _jumping
        extern  _pasteScreen
        extern  _spriteBuffer
        extern  _xPos
        extern  _ySpeed
        extern  decBCD
        extern  display2BCD
        extern  displayPixelTile
        extern  gameOver
        extern  heartCount
        extern  playerSprite
        extern  startSprite
        extern  wyz_play_song
        extern  xyPos
        extern  xyStartPos

        public  die

        include "defs.inc"

        section CODE_2

        ;
        ; Routine called when plater dies.
        ;
die:
        push    af
        push    bc
        push    de
        push    hl

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

        ;
        ; Start the death march
        ;
        ld      a, DEATH_MARCH
        di
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

        ;
        ; Remove the headstone
        ;
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _pasteScreen

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

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret
