        extern  setAttr

        public  _printChar
        public  print
        public  printAttr
        public  printChar
        public  font

        section CODE_4

        #include    "defs.inc"

        ;
        ; Display a char at the specified location.
        ; Callable from 'C', parameters are passed on
        ; the stack.
        ;
        defvars 0                       ; Define the stack variables used
        {
            yPos        ds.b 2
            xPos        ds.b 2
            char        ds.b 2
        }

_printChar:
        entry

        ld      b, (ix+yPos)
        ld      c, (ix+xPos)
        ld      a, (ix+char)

        call    printChar

        exit
        ret

        ;
        ; Display a string with attributes.
        ;
        ;	Entry:
        ;		hl - Pointer to string
        ;		b  - Y screen start position
        ;		c  - X screen start position
        ;		a  - Screen attributes
        ;
        ;	Exit:
        ;		hl - Points to the memory location following the strings
        ;			 null terminator.
        ;		c  - Screen X position following the string
        ;
printAttr:
        push    af
        push    de
        ld      e, a
L1b:
        ld      a, (hl)
        inc     hl
        or      a
        jr      z, L1f

        call    printChar

        ld      a, e
        call    setAttr

        inc     c
        jr      L1b
L1f:
        pop     de
        pop     af
        ret

        ;
        ; Display a string.
        ;
        ;	Entry:
        ;		hl - Pointer to string
        ;		b  - Y screen start position
        ;		c  - X screen start position
        ;
        ;	Exit:
        ;		hl - Points to the memory location following the strings
        ;			 null terminator.
        ;		c  - Screen X position following the string
        ;
print:
        push    af
L2b:
        ld      a, (hl)
        inc     hl
        or      a
        jr      z, L2f

        call    printChar

        inc     c
        jr      L2b
L2f:
        pop     af
        ret

        ;
        ; Display a character at the specified position.
        ;
        ; Input:
        ;		b - Y character position
        ;		c - X character position
        ;		a - Character to display
        ;
printChar:
        push    af
        push    bc
        push    hl

IF  _ZXN
        extern  displayTile
        ; Clear the tile over the character
        ld      l, a
        ld      a, ID_BLANK
        call    displayTile
        ld      a, l
ENDIF

        sub     ' '                     ; Font data starts at <SPACE>
        ld      l, a                    ; Get char to display
        ld      h, 0
        hlx     8

        outChar font

        pop     hl
        pop     bc
        pop     af
        ret

        section RODATA_4
font:
        binary  "Torment.ch8"
        ; Sad face ASCII 0x80 (128)
        defb    60
        defb    66
        defb    165
        defb    129
        defb    153
        defb    165
        defb    66
        defb    60
