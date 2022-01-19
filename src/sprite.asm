IF  !_ZXN

        public  _copyScreen
        public  _pasteScreen
        public  _displaySprite
        public  playerSprite

        #include    "defs.inc"

        section CODE_2

        ;
        ; Copy a portion of screen memory to the buffer pointed to by DE.
        ; The amount of screen copied is 3 x 16 bytes. The screen row addresses
        ; are calculated and stored in addressTab.
        ;
        ; Entry:
        ;		de - Pointer to buffer
        ;		b  - Start pixel y location
        ;		c  - Start pixel x location
        ;
_copyScreen:
        di
        ld      (copyTempSP+1), sp      ; Optimization, self modifying code

        calculateRow    b

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; char offset.

        ld      b, c                    ; Move x char offset to B
        ld      c, -1                   ; Ensure C doesn't wraparound when using ldi

        DEFL    tabAddr=addressTab

        REPT    16
        pop     hl                      ; get screen row address
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
        ; Copy the contents of the buffer pointed to by HL to the screen.
        ; The amount of buffer copied is 3 x 16 bytes. The screen row
        ; addresses are stored in addressTab, which is populated by _copyScreen.
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

        ;
        ; Display the knight sprite at the specified screen location.
        ;
        ; Entry:
        ;       c  - Screen x pixel location
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
ENDIF
