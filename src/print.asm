        extern  setAttr

        public  _printChar
        public  print
        public  printAttr
        public  printChar

        section CODE_4

        include "defs.inc"

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

        di
        ld      (TempSP+1), sp

        sub     ' '                     ; Font data starts at <SPACE>
        ld      l, a                    ; Get char to display
        ld      h, 0
        hlx     8
        ld      sp, FONT
        add     hl, sp

        ; Point the stack at the font data
        ld      sp, hl

        ; Calculate the screen address
        ld      a, b                    ; Y character position
        rrca                            ; Move lower 3 bits to the upper 3 bits
        rrca
        rrca
        and     %11100000               ; Bits 5-3 of pixel row
        or      c                       ; X character position
        ld      l, a

        ld      a, b                    ; Y character position
        and     %00011000               ; Bits 7-6 of pixel row
        or      0x40                    ; 0x40 or 0xc0
        ld      h, a

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h                       ; Add 256 to screen address
        ld      (hl), b
        inc     h                       ; Add 256 to screen address

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b

        ; Restore the stack pointer.
TempSP:
        ld      sp, 0x0000
        ei

        pop     hl
        pop     bc
        pop     af
        ret
