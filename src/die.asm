        extern  heartCount
        extern  subBCD
        extern  display2BCD
        extern  gameOver
        extern  xyPos
        extern  xyStartPos
        extern  _jumping
        extern  _ySpeed
        extern  _falling
        extern  wyz_play_song

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
        ; Start the death march
        ;
        ld      a, DEATH_MARCH
        call    wyz_play_song

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
        ld      l, 0x01
        ld      de, heartCount
        call    subBCD
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

		; Set player X/Y position to where
		; they entered the level.
        ld      hl, (xyStartPos)
        ld      (xyPos), hl
        xor     a
        ld      (_jumping), a
        ld      (_ySpeed), a
        ld      (_falling), a

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret
