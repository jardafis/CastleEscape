        extern  printChar

        public  displayHEX
        public  display2HEX

        #include    "defs.inc"
        section CODE_2

        ; On entry:
        ;       a = Hex value to be displayed
        ;       bc = Character screen location b=Ypos, c=XPos
        ;
        ;       All registers are preserved
displayHEX:
        push    af
        push    hl

        and     0x0f
        ld      hl, hex
        addhl   a
        ld      a, (hl)

        bcall   printChar

        pop     hl
        pop     af
        ret

        ;
        ; Display 2 hex digits
        ;
        ;   Entry:
        ;       b  - Y screen position
        ;       c  - X screen position
        ;       a  - Hex value to display
        ;
display2HEX:
        push    af
        push    bc

        inc     c
        call    displayHEX
        rrca
        rrca
        rrca
        rrca
        dec     c
        call    displayHEX

        pop     bc
        pop     af
        ret

        section RODATA_2
hex:
        db      "0123456789abcdef"
