        extern  currentBank
        extern  __BANKING_STACK_tail
        public  banked_call

        #include    "defs.inc"

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
        ;		dw		<bankedFunction>
        ;       dw      <newBank>
        ; retAddr: <- actual return address from this function
        ;
        section CODE_2
banked_call:
        di
        exx
        ex      af, af'

        pop     hl                      ; Return address

        ld      (saveSP1+1), sp         ; Save the main SP
        ld      sp, (tempsp)            ; Get banking SP

        ld      a, (currentBank)
        push    af                      ; Save the current bank number

        ld      e, (hl)                 ; Fetch the call address
        inc     hl
        ld      d, (hl)
        inc     hl
        ld      a, (hl)                 ; ...and page
        inc     hl
        inc     hl                      ; Yes this should be here

        push    hl                      ; Push the real return address

        ld      (tempsp), sp            ; Save banking SP
saveSP1:
        ld      sp, -1                  ; Restore main SP

        ld      bc, IO_BANK
        ld      (currentBank), a
        out     (c), a

        ld      hl, continue
        push    hl                      ; Return address
        push    de                      ; Banked call address

        exx
        ex      af, af'
        ei

        ret                             ; Jump to banked call

continue:
        di
        exx
        ex      af, af'

        ld      (saveSP2+1), sp

        ld      sp, (tempsp)
        pop     bc                      ; Get the return address
        pop     af                      ; Pop the old bank
        ld      (tempsp), sp

saveSP2:
        ld      sp, -1

        push    bc                      ; Return address

        ld      bc, IO_BANK
        ld      (currentBank), a
        out     (c), a

        exx
        ex      af, af'
        ei

        ret

        SECTION DATA_2
tempsp:
        dw      __BANKING_STACK_tail
