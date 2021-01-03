        extern  _screenTab

        section code_user

        public  _copyScreen
        public  _pasteScreen
        public  _displaySprite

        include "defs.asm"
        ; After entry:
        ;	ix + 0 = sprite x position in pixels
        ;	ix + 1 = sprite y position in pixels
        ;	ix + 2 = buffer pointer lo byte
        ;	ix + 3 = buffer pointer hi byte
        defc    X_OFFSET			= 0x00
        defc    Y_OFFSET			= 0x01
        defc    BUFFER_LO			= 0x02
        defc    BUFFER_HI			= 0x03
_copyScreen:
		entry

        di      
        ld      (copyTempSP),sp         ; Optimization, self modifying code

        ; Claculate the screen Y address
        ld      h,0
        ld      l,(ix+Y_OFFSET)         ; get the y position
        add     hl,hl                   ; multiply by 2
        ld      sp,_screenTab
        add     hl,sp
        ld      sp,hl


        ; Get buffer destination address
        ld      e,(ix+BUFFER_LO)
        ld      d,(ix+BUFFER_HI)


        ld      c,(ix+X_OFFSET)         ; Get the X offset
        srl     c                       ; divide by 8 to get byte address
        srl     c
        srl     c
        ld      b,8
.copyloop
        pop     hl                      ; get screen row source adress
        ld      a,l
        add     c                       ; add x offset
        ld      l,a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a,(hl)
        ld      (de),a
        inc     de
        ; No need to increment hl because we will pop a new one
        ; at the beginning of the loop
        djnz    copyloop

.copyTempSP = $+1
        ld      sp,0x0000
        ei      

		exit
        ret     

        ; After entry:
        ;	ix + 0 = sprite x position in pixels
        ;	ix + 1 = sprite y position in pixels
        ;	ix + 2 = buffer pointer lo byte
        ;	ix + 3 = buffer pointer hi byte
_pasteScreen:
		entry

        di      
        ld      (pasteTempSP),sp

        ; Claculate the screen Y address
        ld      h,0
        ld      l,(ix+Y_OFFSET)         ; get the y position
        add     hl,hl                   ; multiply by 2
        ld      sp,_screenTab
        add     hl,sp
        ld      sp,hl

        ; Get buffer source address
        ld      l,(ix+BUFFER_LO)
        ld      h,(ix+BUFFER_HI)

        ld      b,8
        ld      c,(ix+X_OFFSET)         ; Get the X offset
        srl     c                       ; divide by 8 to get byte address
        srl     c
        srl     c
.pasteloop
        pop     de                      ; get screen row destination adress
        ld      a,e
        add     c                       ; add x offset
        ld      e,a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a,(hl)
        ld      (de),a
        inc     hl
        ; No need to increment de because we will pop a new one
        ; at the beginning of the loop
        djnz    pasteloop

.pasteTempSP = $+1
        ld      sp,0x0000
        ei      

		exit
        ret     

        ; After entry:
        ;	ix + 0 = sprite x position in pixels
        ;	ix + 1 = sprite y position in pixels
_displaySprite:
		entry

        di      
        ld      (displaySpriteSP),sp

        ; Calculate the offset into the screen table
        ld      h,0
        ld      l,(ix+Y_OFFSET)         ; get the y position
        add     hl,hl                   ; multiply by 2
        ld      sp,_screenTab
        add     hl,sp
        ld      sp,hl

        ld      a,(ix+X_OFFSET)         ; Get the X offset
        ld      c,a                     ; Store it
        and     0x07                    ; Get the sprite shift index
        ; Multiply by 32
        add     a                       ; x2
        add     a                       ; x4
        add     a                       ; x8
        add     a                       ; x16
        add     a                       ; x32
        ld      h,0
        ld      l,a
        ld      de,spriteShift0
        add     hl,de
        ex      de,hl

        ; c is the pixel X offset
        ; Divide by 8 to get byte address
        srl     c                       ; /2
        srl     c                       ; /4
        srl     c                       ; /8
        ld      b,8                     ; Sprite height
.loop2
        pop     hl                      ; get screen row adress
        ld      a,l
        add     a,c                     ; add x offset
        ld      l,a

        ld      a,(de)                  ; Get mask data
        and     (hl)                    ; Logical AND screen data with mask
        ld      (hl),a                  ; Store result back to screen
        inc     de                      ; Next byte of sprite data
        ld      a,(de)                  ; Get sprite data
        or      (hl)                    ; Logical OR screen data with sprite data
        ld      (hl),a                  ; Store result back to the screen
        inc     de                      ; Next byte of sprite data

        inc     hl                      ; Next screen X address

        ld      a,(de)                  ; Get mask data
        and     (hl)                    ; Logical AND screen data with mask
        ld      (hl),a                  ; Store result back to screen
        inc     de                      ; Next byte of sprite data
        ld      a,(de)                  ; Get sprite data
        or      (hl)                    ; Logical OR screen data with sprite data
        ld      (hl),a                  ; Store result back to the screen
        inc     de                      ; Next byte of sprite data

        djnz    loop2
.displaySpriteSP = $+1
        ld      sp,0x0000
        ei      

		exit
        ret     

        section rodata_user
        ; 	  mask,      data,     mask,     data
.spriteShift0
        db      11000011b, 00000000b,11111111b,00000000b
        db      10000001b, 00111100b,11111111b,00000000b
        db      00000000b, 01111110b,11111111b,00000000b
        db      00000000b, 01100110b,11111111b,00000000b
        db      00000000b, 01100110b,11111111b,00000000b
        db      00000000b, 01111110b,11111111b,00000000b
        db      10000001b, 00111100b,11111111b,00000000b
        db      11000011b, 00000000b,11111111b,00000000b
.spriteShift1
        db      11100001b,00000000b,11111111b,00000000b
        db      11000000b,00011110b,11111111b,00000000b
        db      10000000b,00111111b,01111111b,00000000b
        db      10000000b,00110011b,01111111b,00000000b
        db      10000000b,00110011b,01111111b,00000000b
        db      10000000b,00111111b,01111111b,00000000b
        db      11000000b,00011110b,11111111b,00000000b
        db      11100001b,00000000b,11111111b,00000000b
.spriteShift2
        db      11110000b,00000000b,11111111b,00000000b
        db      11100000b,00001111b,01111111b,00000000b
        db      11000000b,00011111b,00111111b,10000000b
        db      11000000b,00011001b,00111111b,10000000b
        db      11000000b,00011001b,00111111b,10000000b
        db      11000000b,00011111b,00111111b,10000000b
        db      11100000b,00001111b,01111111b,00000000b
        db      11110000b,00000000b,11111111b,00000000b
.spriteShift3
        db      11111000b,00000000b,01111111b,00000000b
        db      11110000b,00000111b,00111111b,10000000b
        db      11100000b,00001111b,00011111b,11000000b
        db      11100000b,00001100b,00011111b,11000000b
        db      11100000b,00001100b,00011111b,11000000b
        db      11100000b,00001111b,00011111b,11000000b
        db      11110000b,00000111b,00111111b,10000000b
        db      11111000b,00000000b,01111111b,00000000b
.spriteShift4
        db      11111100b,00000000b,00111111b,00000000b
        db      11111000b,00000011b,00011111b,11000000b
        db      11110000b,00000111b,00001111b,11100000b
        db      11110000b,00000110b,00001111b,01100000b
        db      11110000b,00000110b,00001111b,01100000b
        db      11110000b,00000111b,00001111b,11100000b
        db      11111000b,00000011b,00011111b,11000000b
        db      11111100b,00000000b,00111111b,00000000b
.spriteShift5
        db      11111110b,00000000b,00011111b,00000000b
        db      11111100b,00000001b,00001111b,11100000b
        db      11111000b,00000011b,00000111b,11110000b
        db      11111000b,00000011b,00000111b,00110000b
        db      11111000b,00000011b,00000111b,00110000b
        db      11111000b,00000011b,00000111b,11110000b
        db      11111100b,00000001b,00001111b,11100000b
        db      11111110b,00000000b,00011111b,00000000b
.spriteShift6
        db      11111111b,00000000b,00001111b,00000000b
        db      11111110b,00000000b,00000111b,11110000b
        db      11111100b,00000001b,00000011b,11111000b
        db      11111100b,00000001b,00000011b,10011000b
        db      11111100b,00000001b,00000011b,10011000b
        db      11111100b,00000001b,00000011b,11111000b
        db      11111110b,00000000b,00000111b,11110000b
        db      11111111b,00000000b,00001111b,00000000b
.spriteShift7
        db      11111111b,00000000b,10000111b,00000000b
        db      11111111b,00000000b,00000011b,01111000b
        db      11111110b,00000000b,00000001b,11111100b
        db      11111110b,00000000b,00000001b,11001100b
        db      11111110b,00000000b,00000001b,11001100b
        db      11111110b,00000000b,00000001b,11111100b
        db      11111111b,00000000b,00000011b,01111000b
        db      11111111b,00000000b,10000111b,00000000b
