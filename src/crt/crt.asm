        include "zcc_opt.def"

        EXTERN  _main
        EXTERN  __BSS_head
        EXTERN  __BSS_END_head

        EXTERN  __BSS_0_head
        EXTERN  __BSS_1_head
        EXTERN  __BSS_2_head
        EXTERN  __BSS_3_head
        EXTERN  __BSS_4_head
        EXTERN  __BSS_5_head
        EXTERN  __BSS_6_head
        EXTERN  __BSS_7_head
        EXTERN  __BSS_0_tail
        EXTERN  __BSS_1_tail
        EXTERN  __BSS_2_tail
        EXTERN  __BSS_3_tail
        EXTERN  __BSS_4_tail
        EXTERN  __BSS_5_tail
        EXTERN  __BSS_6_tail
        EXTERN  __BSS_7_tail

IFNDEF CRT_INITIALIZE_BSS
		DEFC	CRT_INITIALIZE_BSS=1
ENDIF

        SECTION CODE
        ORG     CRT_ORG_CODE
        SECTION code_crt_init
crt0:
        di
        ;
        ; Fill the stack with a known pattern so
        ; we can see how much we are using.
        ;
        ; Interrupts should be disabled so no need to worry
        ; about ISR accessing the stack.
        ;
        ld      sp, REGISTER_SP
fillStack:
        ld      de, 0x5555              ; Word to fill
        ld      b, CRT_STACK_SIZE/2     ; Stack size in words
fillStackLoop:
        push    de                      ; Push data to stack
        djnz    fillStackLoop           ; Loop for all words
        ld      sp, REGISTER_SP

        SECTION code_crt_main
IF CRT_INITIALIZE_BSS
        call    bssInit
ENDIF
        call    _main

        SECTION code_crt_exit
        di
        halt

		;
		; Clear the BSS sections
		;
bssInit:
        ld      (bssInitDone+1), sp
        ld      sp, bssTable
nextBSSSection:
        pop     bc                      ; BSS size
        pop     hl                      ; BSS start
        ld      a, b                    ; Check if the BSS size is 0
        or      c                       ; If it is, skip to
        jr      z, nextBSSSection       ; the next BSS section in the table

        bit     7, b                    ; If bit 7 of BC is set
        jr      nz, bssInitDone         ; End of table.

        dec     bc                      ; Decrement length

		; Switch memory banks somewhere here

        ld      (hl), 0                 ; Zero contents of HL
        ld      de, hl
        inc     de                      ; DE = HL + 1
        ldir                            ; Fill
        jr      nextBSSSection
bssInitDone:
        ld      sp, 0xffff
        ret


        SECTION code_crt0_sccz80
        SECTION code_user
        SECTION CODE_END

        SECTION RODATA
        SECTION rodata_user
bssTable:
        dw      __BSS_END_head-__BSS_head
        dw      __BSS_head
        dw      __BSS_0_tail-__BSS_0_head
        dw      __BSS_0_head
        dw      __BSS_1_tail-__BSS_1_head
        dw      __BSS_1_head
        dw      __BSS_2_tail-__BSS_2_head
        dw      __BSS_2_head
        dw      __BSS_3_tail-__BSS_3_head
        dw      __BSS_3_head
        dw      __BSS_4_tail-__BSS_4_head
        dw      __BSS_4_head
        dw      __BSS_5_tail-__BSS_5_head
        dw      __BSS_5_head
        dw      __BSS_6_tail-__BSS_6_head
        dw      __BSS_6_head
        dw      __BSS_7_tail-__BSS_7_head
        dw      __BSS_7_head
        dw      0x8000

        SECTION RODATA_END

        SECTION DATA
        SECTION data_user
        SECTION DATA_END

        SECTION BSS
        SECTION bss_user
        SECTION BSS_END


		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   		; Define Memory Banks
   		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IFNDEF  CRT_ORG_BANK_0
        defc    CRT_ORG_BANK_0=0x00c000
ENDIF

IFNDEF  CRT_ORG_BANK_1
        defc    CRT_ORG_BANK_1=0x01c000
ENDIF

IFNDEF  CRT_ORG_BANK_2
        defc    CRT_ORG_BANK_2=0x02c000
ENDIF

IFNDEF  CRT_ORG_BANK_3
        defc    CRT_ORG_BANK_3=0x03c000
ENDIF

IFNDEF  CRT_ORG_BANK_4
        defc    CRT_ORG_BANK_4=0x04c000
ENDIF

IFNDEF  CRT_ORG_BANK_5
        defc    CRT_ORG_BANK_5=0x05c000
ENDIF

IFNDEF  CRT_ORG_BANK_6
        defc    CRT_ORG_BANK_6=0x06c000
ENDIF
IFNDEF  CRT_ORG_BANK_7
        defc    CRT_ORG_BANK_7=0x07c000
ENDIF


        SECTION BANK_0
        org     CRT_ORG_BANK_0
        SECTION CODE_0
        SECTION RODATA_0
        SECTION DATA_0
        SECTION BSS_0
        SECTION BANK_0_END

        SECTION BANK_1
        org     CRT_ORG_BANK_1
        SECTION CODE_1
        SECTION RODATA_1
        SECTION DATA_1
        SECTION BSS_1
        SECTION BANK_1_END

        SECTION BANK_2
        org     CRT_ORG_BANK_2
        SECTION CODE_2
        SECTION RODATA_2
        SECTION DATA_2
        SECTION BSS_2
        SECTION BANK_2_END

        SECTION BANK_3
        org     CRT_ORG_BANK_3
        SECTION CODE_3
        SECTION RODATA_3
        SECTION DATA_3
        SECTION BSS_3
        SECTION BANK_3_END

        SECTION BANK_4
        org     CRT_ORG_BANK_4
        SECTION CODE_4
        SECTION RODATA_4
        SECTION DATA_4
        SECTION BSS_4
        SECTION BANK_4_END

        SECTION BANK_5
        org     CRT_ORG_BANK_5
        SECTION CODE_5
        SECTION RODATA_5
        SECTION DATA_5
        SECTION BSS_5
        SECTION BANK_5_END

        SECTION BANK_6
        org     CRT_ORG_BANK_6
        SECTION CODE_6
        SECTION RODATA_6
        SECTION DATA_6
        SECTION BSS_6
        SECTION BANK_6_END

        SECTION BANK_7
        org     CRT_ORG_BANK_7
        SECTION CODE_7
        SECTION RODATA_7
        SECTION DATA_7
        SECTION BSS_7
        SECTION BANK_7_END

