        public  _cls
        public  clearAttr
        public  setAttr
        section code_user

        include "defs.inc"

        ;
        ; Clear the screen bitmap and attr data.
        ;
        ; On entry, l contains the attribute to fill the attr memory.
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
setAttr:
        push    bc
        push    hl
        ld      l, b
        ld      h, 0
        hlx     32
        ld      b, 0
        add     hl, bc
        ld      bc, SCREEN_ATTR_START
        add     hl, bc
        ld      (hl), a
        pop     hl
        pop     bc
        ret

        section bss_user
clsAttrib:
        ds      1
