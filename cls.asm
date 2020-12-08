        public  _cls
        section code_user

        include "defs.asm"

        ;
        ; Clear the screen bitmap and attr data.
        ;
        ; On entry, l contains the attribute to fill the attr memory.
        ;
_cls:
        push    bc
        push    hl

        di      
        ld      (l_tempSP),sp

        ld      sp,SCREEN_ATTR_END
        ld      h,l                     ; attr input parameter in l
        ; If we devide the attr length by 4 it will
        ; fit in 8 bits and we can use djnz
        ld      b,SCREEN_ATTR_LENGTH/4
.loop2
        ; Push 4 bytes into screen attr memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        djnz    loop2

        ld      hl,0                    ; data to fill
        ; If we devide the screen length by 32 it will
        ; fit in 8 bits and we can use djnz
        ld      b,SCREEN_LENGTH/32
.loop
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

        ld      sp,(l_tempSP)
        ei      

        pop     hl
        pop     bc
        ret     

        section bss_user
.l_tempSP
        dw      0
