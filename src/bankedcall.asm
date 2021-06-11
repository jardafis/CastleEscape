        extern  currentBank
        public  bankedCall

        section CODE_2

        include "defs.inc"

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
