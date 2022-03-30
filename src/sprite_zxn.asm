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

        public  _displaySprite
        public  playerSprite

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
        xor     a                       ; 4
        cp      l                       ; 4
        jr      nz, setJumpSprite
        cp      h                       ; 4
        jr      nz, setFallSprite

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
        ld      a, (_ySpeed)
        add     SPRITE_ID_JUMP
        jr      setSprite
setFallSprite:
        ld      a, SPRITE_ID_JUMP
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
playerSprite:
        ds      2
frame:
        ds      1
ENDIF
