IF  _ZXN
        extern  knightSprite
        extern  setSpritePattern
        extern  setSpriteXY
        extern  setSpriteFlip
        extern  updateSpriteAttribs
        extern  _ySpeed
        extern  _xSpeed
        extern  jumpFall
        extern  ticks
        extern  playerSprite

        public  _displaySprite

        #include    "defs.inc"

        section CODE_2

        ;
        ; Display the knight sprite at the specified screen location.
        ;
        ; Entry:
        ;       b  - Screen y pixel location
        ;       c  - Screen x pixel location
        ;
_displaySprite:
        ld      a, (ticks)
        and     0x01
        ret     z

        ld      hl, (jumpFall)          ; 16
        ld		a, h
        or		l
        jr		nz, setJumpSprite

        call    getPatternIndex
        add     SPRITE_ID_KNIGHT        ; Sprite pattern offset

setSprite:
        ld      ix, knightSprite
        call    setSpritePattern

        call    setSpriteXY

        ld      a, (playerSprite)
        call    setSpriteFlip

        call    updateSpriteAttribs
        ret
setJumpSprite:
        ld      de, (_ySpeed)
        fix_to_int  d, e
        or      a
        ld      a, SPRITE_ID_JUMP_UP
        jp      m, setSprite
        ld      a, SPRITE_ID_JUMP_PEEK
        jr      z, setSprite
        ld      a, SPRITE_ID_FALL
        jr      setSprite

getPatternIndex:
		; Check if the player is moving left/right
        ld      a, (_xSpeed)
        or      a
        ret     z

        ; Increment the frame count
        ld      hl, frame               ; 10
        inc     (hl)                    ; 11
        ld      a, (hl)                 ; 7
        mod     5

        ret

        section BSS_2
frame:
        ds      1
ENDIF
