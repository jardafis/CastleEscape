        extern  currentBank
        public  bankedCall

        section CODE_2

        include "defs.inc"

		;
		; Input:
		;		SP+0 - Return address for this function
		;		SP+2 - Bank number for banked routine
		;		SP+4 - Address of banked routine
		;
		; Note:
		;		Alternate register set is used for temporary
		;		storage.
		;
bankedCall:
        ex      af, af'                 ; Save all regs
        exx

        ld      a, (currentBank)        ; Get the current bank number
        ld      d, a                    ; Save it

        pop     hl                      ; Get the return address for this function
        pop     af                      ; Get the new bank number
		; Switch to the new bank
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

        pop     bc                      ; Address of banked function

		;
		; Build the new stack frame
		;

        push    hl                      ; Return address from this function
        push    de                      ; Save the old bank number

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
        pop     af                      ; Get the old bank number from the stack

		; Map in the old bank
        push    bc
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a
        pop     bc

        ex      af, af'                 ; Restore af from the banked call
		; All registers are from the banked function
        ret
