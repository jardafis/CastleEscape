        public  _cls
        public  clearAttr
        public  setAttr
IF  _ZXN
        extern  clearTilemap
ENDIF
        section CODE_2

        #include    "defs.inc"

        ;
        ; Clear the screen bitmap and attr data.
        ;
        ; On entry, l contains the attribute to fill the attr memory.
        ;
        ; Notes: Interrupts must be enabled as 'halt' is used to sync to
        ; the screen refresh.
        ;
_cls:
        push    af
        push    bc
        push    hl

        ld      a, l
        ld      (clsAttrib), a

        halt

        di
        ld      (clsTempSP+1), sp

        ld      sp, SCREEN_ATTR_END
        ld      h, l                    ; attr input parameter in l
        ; If we divide the attr length by 4 it will
        ; fit in 8 bits and we can use djnz
        ld      b, SCREEN_ATTR_LENGTH/4
loop2:
        ; Push 4 bytes into screen attr memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        djnz    loop2

        ld      hl, 0                   ; data to fill
        ; If we divide the screen length by 32 it will
        ; fit in 8 bits and we can use djnz
        ld      b, SCREEN_LENGTH/32
loop:
        ; Push 32 bytes of 0 into the screen memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        djnz    loop
clsTempSP:
        ld      sp, -1
        ei

IF  _ZXN
        call    clearTilemap
ENDIF

        pop     hl
        pop     bc
        pop     af
        ret

        ;
        ; Set the screen attribute specified by 'bc' to
        ; the attribute used to last clear the screen.
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;
clearAttr:
        push    af
        ld      a, (clsAttrib)
        call    setAttr
        pop     af
        ret

        ;
        ; Set the screen attribute specified by 'bc' to
        ; the attribute passed in 'a'.
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;		a - Attribute
        ;
        ; Notes:
        ;	'a' is not preserved.
        ;
setAttr:
        push    hl

        ld      (attribVal+1), a

        ld      a, b
        rrca
        rrca
        rrca
        ld      h, a
        and     %11100000
        or      c
        ld      l, a

        ld      a, h
        and     %00000011
        or      SCREEN_ATTR_START>>8
        ld      h, a

attribVal:
        ld      (hl), -1

        pop     hl
        ret

        section BSS_2
clsAttrib:
        ds      1
