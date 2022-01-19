IF  _ZXN
        extern  knightSprite
        extern  setSpritePattern
        extern  setSpriteXY
        extern  setSpriteFlip
        extern  updateSpriteAttribs
        extern  _jumping

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

        ld      a, c
        and     0x03

setSprite:
        ld      ix, knightSprite
        call    setSpritePattern

        call    setSpriteXY

        ld      a, (playerSprite)
        call    setSpriteFlip

        call    updateSpriteAttribs
        ret
setJumpSprite:
        ld      a, SPRITE_ID_JUMP
        jr      setSprite

        section BSS_2
playerSprite:
        ds      2
ENDIF
