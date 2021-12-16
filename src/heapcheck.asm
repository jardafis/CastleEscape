        extern  printAttr

        public  heapCheck

        #include "defs.inc"

        section CODE_2

        ; Check if the heap tail pointer has overflowed.
        ;
        ; If the heap tail > the heap limit a message
        ; will be displayed and the routine asserts.
        ;
        ; Entry:
        ;   hl = Heap limit
        ;   de = Heap tail
        ;
heapCheck:
        ; Check for heap overflow
        xor     a                       ; Clear carry flag
        sbc     hl, de
        ret     nc

        ld      b, a
        ld      c, b
        ld      a, INK_RED|PAPER_WHITE|BRIGHT|FLASH
        ld      hl, heapMsg
        bcall   printAttr
        assert

        section RODATA_2
heapMsg:
        db      "Fatal: Heap overflow!", 0x00
