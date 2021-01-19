        extern  _screenTab

		public	addBCD
		public	incBCD
        public  _displayBCD
        public	display2BCD

        include "defs.asm"
        section code_user

        ; On entry:
        ;		a[3:0] = BCD value to display, a[7:4] must be zero
        ;		bc = Character screen location b=Xpos, c=YPos
        ;
        ;		All registers are preserved
_displayBCD:
        push    af
        push    bc
        push    de
        push    hl

        ld      h,0
        add     a                       ; x2
        add     a                       ; x4
        add     a                       ; x8
        ld      l,a
        ld      de,FONT + (('0' - 32) * 8); Start address of numbers in font
        add     hl,de                   ; Pointer to start of character in ROM font
        push    hl                      ; Save font pointer address

        ld      h,0
        ld      l,c
        hlx     16                      ; x16
        ld      de,_screenTab
        add     hl,de                   ; Pointer to screenTab entry

        ; Get the screen table entry into de
        ld      a,(hl)
        add     b                       ; Add x position to low 8 bits of the screen address
        ld      e,a
        inc     hl
        ld      d,(hl)

        pop     hl                      ; Restore font pointer

        ; Display a single digit 0 - 9
        ldi     
        dec     e                       ; Incremented by ldi so decrement it
        inc     d                       ; Add 256 for next screen row
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d
        ldi     
        dec     e
        inc     d

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

display2BCD:
        push    af
        push    bc

        xor     a                       ; Zero a

        rld                             ; Get high order nibble from (hl)
        call    _displayBCD             ; Display the character
        inc     b                       ; Increment x screen location
        rld                             ; Get low order nibble from (hl)
        call    _displayBCD
        inc     b                       ; Increment x screen location
        rld                             ; Put the low order nibble back in (hl)

        pop     bc
        pop     af
        ret

        ;
        ; Add the BCD value in 'l' to the BCD value pointed to by 'de'.
        ;
        ;	Entry:
        ;		de - Pointer to BCD value to be incremented
        ;		l  - BCD value to be added
        ;
addBCD:
        push    af
        push    de

        ld      a,(de)                  ; Get low byte of BCD value
        add     l                       ; Add the BCD value passed in
        daa                             ; Adjust result for BCD
        ld      (de),a                  ; Save the updated BCD value
        jr      nc,addScoreDone         ; If nc, no wraparound

        inc     de                      ; There was a wraparound
        ld      a,(de)                  ; Get high byte of BCD value
        or      a                       ; Clear the carry flag
        inc     a                       ; Increment the value
        daa                             ; Adjust result for BCD
        ld      (de),a                  ; Save the incremented BCD value

.addScoreDone
        pop     de
        pop     af
        ret

        ;
        ; Increment the BCD value pointed to by 'de'
        ;
        ;	Entry:
        ;		de - Pointer to BCD value to be incremented
        ;
incBCD:
        push    hl

        ld      l,1
        call    addBCD

        pop     hl
        ret


