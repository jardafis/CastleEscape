        extern  _screenTab
        extern	_LeftSprite0
        extern	_RightSprite0

        section code_user

        public  _copyScreen
        public  _pasteScreen
        public  _displaySprite
		public	playerSprite

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


        ld      a,(ix+X_OFFSET)         ; Get the X offset
        rrca
        rrca
        rrca
        and		%00011111
        ld		c,a
        ld      b,PLAYER_HEIGHT
.copyloop
        pop     hl                      ; get screen row source adress
        ld      a,l
        add     c                       ; add x offset
        ld      l,a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
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

        ld      b,PLAYER_HEIGHT
        ld      a,(ix+X_OFFSET)         ; Get the X offset
        rrca	                        ; divide by 8 to get byte address
        rrca
        rrca
        and		%00011111
        ld		c,a
.pasteloop
        pop     de                      ; get screen row destination adress
        ld      a,e
        add     c                       ; add x offset
        ld      e,a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
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
        ld		l,a
        ld		h,0
        ; Multiple by 96
		hlx		32
		ld		de,hl					; Save 32x
		hlx		2						; 64x
		add		hl,de					; Add 32x
        ld      de,(playerSprite)
        add     hl,de
        ex      de,hl

        ; c is the pixel X offset
        ; Divide by 8 to get byte address
        srl     c                       ; /2
        srl     c                       ; /4
        srl     c                       ; /8
        ld      b,PLAYER_HEIGHT         ; Sprite height
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

		section	bss_user
.playerSprite
		dw		0
