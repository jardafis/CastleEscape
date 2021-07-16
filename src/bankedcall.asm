        extern  currentBank
        public  bankedCall

        section CODE_2

        include "defs.inc"

        ; 0xffff +--------+--------+--------+--------+--------+--------+--------+--------+
        ;        | Bank 0 | Bank 1 | Bank 2 | Bank 3 | Bank 4 | Bank 5 | Bank 6 | Bank 7 |
        ;        |        |        |(also at|        |        |(also at|        |        |
        ;        |        |        | 0x8000)|        |        | 0x4000)|        |        |
        ;        |        |        |        |        |        | screen |        | screen |
        ; 0xc000 +--------+--------+--------+--------+--------+--------+--------+--------+
        ;        | Bank 2 |        Any one of these pages may be switched in.
        ;        |        |
        ;        |        |
        ;        |        |
        ; 0x8000 +--------+
        ;        | Bank 5 |
        ;        |        |
        ;        |        |
        ;        | screen |
        ; 0x4000 +--------+--------+
        ;        | ROM 0  | ROM 1  | Either ROM may be switched in.
        ;        |        |        |
        ;        |        |        |
        ;        |        |        |
        ; 0x0000 +--------+--------+
        ;
        ; Note:
        ;		Alternate register set is used for temporary
        ;		storage.
        ;
        ; Calling Convention:
        ; 		call	bankedCall
        ;		db		<newBank>
        ;		dw		<bankedFunction>
        ; retAddr: <- actual return address from this function
        ;
bankedCall:
        ex      af, af'
        exx

        ld      a, (currentBank)        ; Get the current bank number
        ld      d, a                    ; and save it.

        pop     hl                      ; Get the return address it points to the new bank
        ld      a, (hl)                 ; New bank number
        inc     hl

        ; Switch to the new bank
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

        ld      c, (hl)                 ; Get the banked routine address
        inc     hl
        ld      b, (hl)
        inc     hl                      ; hl now points to the address actual return address

        ;
        ; Build the new stack frame
        ;

        push    hl                      ; Return address from this function
        push    de                      ; The old bank number

        ld      hl, bankedReturn
        push    hl                      ; Return address from banked function
        push    bc                      ; Address of banked routine

        exx                             ; Restore all the regs
        ex      af, af'

        ; All registers are passed into the banked call
        ret                             ; Jump to banked routine address on the stack

        ;
        ; Banked routines will return here
        ;
bankedReturn:
        ex      af, af'                 ; Save af from the banked call
        exx

        pop     af                      ; Get the old bank number from the stack

        ; Map in the old bank
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

        exx
        ex      af, af'                 ; Restore af from the banked call

        ; All registers from the banked function are available here
        ret
