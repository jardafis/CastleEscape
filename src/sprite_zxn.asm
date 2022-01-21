IF  _ZXN
        extern  knightSprite
        extern  setSpritePattern
        extern  setSpriteXY
        extern  setSpriteFlip
        extern  updateSpriteAttribs
        extern  _jumping
        extern  _ySpeed
        extern  _falling

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
        ld      a, (_jumping)
        or      a
        jr      nz, setJumpSprite
        ld      a, (_falling)
        or      a
        jr      nz, setFallSprite

        call    patternIndex
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

patternIndex:
        ld      a, c
        mod     5

        push    af
        ld      a, (playerSprite)
        rrca
        jr      c, leftPattern
        pop     af
        ret

leftPattern:
        pop     af
        sub     4
        neg
        ret

        section BSS_2
playerSprite:
        ds      2
ENDIF
