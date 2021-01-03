        public  _displayBCD
        extern  _screenTab

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
		hlx		16                               ; x16
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

