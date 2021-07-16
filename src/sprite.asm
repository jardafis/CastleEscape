        extern  _screenTab

        public  _copyScreen
        public  _displaySprite
        public  _pasteScreen
        public  playerSprite

        include "defs.inc"

        section CODE_2

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
        ld      b, PLAYER_HEIGHT
copyloop:
        pop     hl                      ; get screen row source adress
        ld      a, l
        add     c                       ; add x offset
        ld      l, a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a, (hl)
        ld      (de), a
        inc     de
        djnz    copyloop

copyTempSP:
        ld      sp, -1
        ei
        ret

        ;
        ; Entry:
        ;		de - Pointer to buffer
        ;		b  - Start screen y location
        ;		c  - Start screen x location
        ;
_pasteScreen:
        di
        ld      (pasteTempSP+1), sp     ; Optimization, self modifying code

        calculateRow    b

        ex      de, hl                  ; Buffer address into hl

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; byte address.
        ld      b, PLAYER_HEIGHT
pasteloop:
        pop     de                      ; get screen row destination adress
        ld      a, e
        add     c                       ; add x offset
        ld      e, a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a, (hl)
        ld      (de), a
        inc     hl
        djnz    pasteloop

pasteTempSP:
        ld      sp, -1
        ei
        ret

        ;
        ; Entry:
        ;		b  - Screen y location
        ;		c  - Screen x location
        ;
_displaySprite:
        di
        ld      (displaySpriteSP+1), sp

        ld      a, c
        and     0x07                    ; Get the sprite shift index

        rrca                            ; Multiply by 32
        rrca
        rrca
        ld      h, a
        and     %11100000
        ld      l, a
        ld      a, h
        and     %00011111
        ld      h, a

        ld      de, hl                  ; Save 32x in de
        hlx     2                       ; 64x
        add     hl, de                  ; 32x + 64x
        ld      de, (playerSprite)
        add     hl, de
        ld      sp, hl                  ; Sprite pointer

        ; Calculate the screen address
        ld      l, b
        ld      h, 0
        add     hl, hl                  ; multiply by 2
        ld      de, _screenTab
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        ex      de, hl

        ld      a, c                    ; X pixel position

        rrca                            ; Divide by 8
        rrca
        rrca

        and     %00011111               ; Mask off garbage bits

        add     l                       ; Add to screen address
        ld      l, a

        ld      c, 0x07
        ld      b, PLAYER_HEIGHT
yLoop:
        pop     de                      ; Pop sprite data
        ld      a, (hl)                 ; Read the screen contents
        and     e                       ; and with mask
        or      d                       ; or with sprite data
        ld      (hl), a                 ; save it back to the screen
        inc     l                       ; Next screen position to the right

        pop     de                      ; Pop sprite data
        ld      a, (hl)                 ; Read the screen contents
        and     e                       ; and with mask
        or      d                       ; or with sprite data
        ld      (hl), a                 ; save it back to the screen
        inc     l                       ; Next screen position to the right

        pop     de                      ; Pop sprite data
        ld      a, (hl)                 ; Read the screen contents
        and     e                       ; and with mask
        or      d                       ; or with sprite data
        ld      (hl), a                 ; save it back to the screen

        dec     l
        dec     l

        inc     h                       ; Next pixel line
        ld      a, h                    ; Check for char boundary crossing
        and     c                       ; and 0x07
        jr      z, nextCharRow

        djnz    yLoop                   ; Loop for next row of sprite

displaySpriteSP:
        ld      sp, -1
        ei
        ret

nextCharRow:
        ; Increment char row
        ld      a, l
        add     0x20
        ld      l, a
        jr      c, nextThird

        ; Same third
        ld      a, h
        sub     0x08
        ld      h, a

nextThird:
        djnz    yLoop                   ; Loop for next row of sprite
        jr      displaySpriteSP

        section BSS_2
playerSprite:
        ds      2
