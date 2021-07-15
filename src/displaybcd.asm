        extern  printChar

        public  addBCD
        public  subBCD
        public  incBCD
        public  decBCD
        public  display4BCD
        public  display2BCD
        public  displayBCD

        include "defs.inc"
        section CODE_2

        ; On entry:
        ;		a[3:0] = BCD value to display, a[7:4] must be zero
        ;		bc = Character screen location b=Ypos, c=XPos
        ;
        ;		All registers are preserved
displayBCD:
        push    af

        add     '0'
        call    printChar

        pop     af
        ret

        ;
        ; Display 2 BCD digits
        ;
        ;	Entry:
        ;		b  - Y screen position
        ;		c  - X screen position
        ;		hl - Pointer to BCD value
        ;
display2BCD:
        push    af
        push    bc

        xor     a                       ; Zero a

        rld                             ; Get high order nibble from (hl)
        call    displayBCD              ; Display the character
        inc     c                       ; Increment x screen location
        rld                             ; Get low order nibble from (hl)
        call    displayBCD
        inc     c                       ; Increment x screen location
        rld                             ; Put the low order nibble back in (hl)

        pop     bc
        pop     af
        ret

        ;
        ; Display 4 BCD digits
        ;
        ;	Entry:
        ;		b  - Y screen position
        ;		c  - X screen position
        ;		hl - Pointer to BCD value
        ;
display4BCD:
        push    bc

        inc     hl
        call    display2BCD
        dec     hl
        inc     c
        inc     c
        call    display2BCD

        pop     bc
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

        ld      a, (de)                 ; Get low byte of BCD value
        add     l                       ; Add the BCD value passed in
        daa                             ; Adjust result for BCD
        ld      (de), a                 ; Save the updated BCD value
        jr      nc, addBCDDone          ; If nc, no wraparound

        inc     de                      ; There was a wraparound
        ld      a, (de)                 ; Get high byte of BCD value
        or      a                       ; Clear the carry flag
        inc     a                       ; Increment the value
        daa                             ; Adjust result for BCD
        ld      (de), a                 ; Save the incremented BCD value

addBCDDone:
        pop     de
        pop     af
        ret

        ;
        ; Subtract the BCD value in 'l' from the BCD value pointed to by 'de'.
        ;
        ;	Entry:
        ;		de - Pointer to BCD value
        ;		l  - BCD value
        ;
subBCD:
        push    af
        push    de

        ld      a, (de)                 ; Get low byte of BCD value
        sbc     l                       ; Add the BCD value passed in
        daa                             ; Adjust result for BCD
cheat:
IFNDEF  CHEAT
        ld      (de), a                 ; Save the updated BCD value
ELSE
        nop                             ; Cheat enabled, do not update
ENDIF
        jr      nc, subBCDDone          ; If nc, no wraparound

        inc     de                      ; There was a wraparound
        ld      a, (de)                 ; Get high byte of BCD value
        or      a                       ; Clear the carry flag
        dec     a                       ; Decrement the value
        daa                             ; Adjust result for BCD
        ld      (de), a                 ; Save the incremented BCD value

subBCDDone:
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

        ld      l, 1
        call    addBCD

        pop     hl
        ret

        ;
        ; Decrement the BCD value pointed to by 'de'
        ;
        ;	Entry:
        ;		de - Pointer to BCD value
        ;
decBCD:
        push    hl

        ld      l, 1
        call    subBCD

        pop     hl
        ret

