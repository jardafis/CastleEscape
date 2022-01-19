IF  !_ZXN
        extern  _screenTab

        public  _copyScreen
        public  _pasteScreen
ELSE
        extern  knightSprite
        extern  setSpritePattern
        extern  setSpriteXY
        extern  setSpriteFlip
        extern  updateSpriteAttribs
        extern  _jumping
ENDIF
        public  _displaySprite
        public  playerSprite

        #include    "defs.inc"

        section CODE_2

IF  !_ZXN
        ;
        ; Entry:
        ;		de - Pointer to buffer
        ;		b  - Start screen y location
        ;		c  - Start screen x location
        ;
_copyScreen:
        di
        ld      (copyTempSP+1), sp      ; Optimization, self modifying code

        calculateRow    b

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; byte address.

        ld      b, c                    ; Move x char offset to B
        ld      c, -1                   ; Ensure C doesn't wraparound when using ldi

        DEFL    var=0
        DEFL    tabAddr=addressTab

        REPT    16

        pop     hl                      ; get screen row source adress
        ld      a, l
        add     b                       ; add x offset
        ld      l, a

        ; Save the screen address in the address table
        ld      (tabAddr), hl
        DEFL    tabAddr=tabAddr+2


        ldi
        ldi
        ldi

        ENDR

copyTempSP:
        ld      sp, -1
        ei
        ret

        ;
        ; Entry:
        ;		hl - Pointer to buffer
        ;
_pasteScreen:
        di
        ld      (pasteTempSP+1), sp     ; Optimization, self modifying code
        ld      sp, addressTab

        REPT    16
        pop     de
        ldi
        ldi
        ldi
        ENDR

pasteTempSP:
        ld      sp, -1
        ei
        ret
ENDIF
IF  _ZXN
        ;
        ; Entry:
        ;		b  - Screen y location
        ;		c  - Screen x location
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

ELSE
        ;
        ; Entry:
        ;       c  - Screen x location
        ;
_displaySprite:
        di
        ld      (displaySpriteSP+1), sp

        ld      a, c                    ; Get X pixel position
        and     0x07                    ; Get the sprite shift index

        add     a                       ; x2
        ld      l, a                    ; Put result in HL
        ld      h, 0
        ld      sp, x96                 ; Pointer to x96 table
        add     hl, sp                  ; x96 table offset
        ld      sp, hl
        pop     de                      ; Sprite offset
        ld      hl, (playerSprite)
        add     hl, de                  ; Sprite address in HL

        ld      sp, hl                  ; Sprite data

        DEFL    val=0

        REPT    16
        ld      de, (addressTab+val)    ; Screen address
        DEFL    val=val+2

        pop     hl                      ; Get sprite data/mask
        ld      a, (de)                 ; Load from screen
        and     l                       ; AND sprite mask
        or      h                       ; OR sprite data
        ld      (de), a                 ; Store to screen
        inc     de                      ; Next screen location to the right

        pop     hl
        ld      a, (de)
        and     l
        or      h
        ld      (de), a
        inc     de

        pop     hl
        ld      a, (de)
        and     l
        or      h
        ld      (de), a
        ENDR

displaySpriteSP:
        ld      sp, -1
        ei
        ret
ENDIF
        section BSS_2
playerSprite:
        ds      2
addressTab:
        ds      16*SIZEOF_ptr

        section RODATA_2
x96:
        dw      96*0
        dw      96*1
        dw      96*2
        dw      96*3
        dw      96*4
        dw      96*5
        dw      96*6
        dw      96*7
