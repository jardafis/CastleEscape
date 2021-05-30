        EXTERN  _main
        EXTERN  __BSS_head
        EXTERN  __BSS_END_head
        EXTERN  __BSS_5_head
        EXTERN  __BSS_5_tail

        DEFC    CRT_ORG_BANK_5=0x5B00
        DEFC    CRT_ORG_CODE=0x8184

        SECTION CODE
        ORG     CRT_ORG_CODE
start:
        di

		;
		; Clear the BSS section
		;
		ld		sp, bssTable
nextBSSSection:
		pop		bc						; BSS size
		pop		hl						; BSS start
		ld		a, b					; Check if the BSS size is 0
		or		c						; If it is, skip to
		jr		z, nextBSSSection		; the next BSS section in the table

		bit		7, b					; If bit 7 of BC is set
		jr		nz, bssInitDone			; End of table.

		dec		bc						; Decrement length

        ld      (hl), 0					; Zero contents of HL
        ld		de, hl					; DE = HL + 1
       	inc		de
		ldir							; Fill
bssInitDone:


;        ld      hl, __BSS_head
;        ld      (hl), 0
;        ld      de, __BSS_head+1
;        ld      bc, __BSS_END_head-__BSS_head-1
;        ldir

		;
		; Set the stack pointer address
		;
        ld      sp, 0x8181

        SECTION code_crt_init

        SECTION code_crt_main
        call    _main

        SECTION code_crt_exit
        di
        halt

        SECTION code_crt0_sccz80
        SECTION code_driver
        SECTION code_user
        SECTION CODE_END

        SECTION RODATA
        SECTION rodata_compiler
        SECTION rodata_user
bssTable:
		dw	__BSS_END_head-__BSS_head
		dw	__BSS_head
		dw	__BSS_5_tail-__BSS_5_head
		dw	__BSS_5_head
		dw	0x8000

        SECTION RODATA_END

        SECTION DATA
        SECTION data_compiler
        SECTION data_user
        SECTION DATA_END

        SECTION BSS
        SECTION bss_compiler
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
        SECTION	DATA_0
        SECTION	BSS_0
        SECTION BANK_0_END

        SECTION BANK_1
        org     CRT_ORG_BANK_1
        SECTION CODE_1
        SECTION RODATA_1
        SECTION	DATA_1
        SECTION	BSS_1
        SECTION BANK_1_END

        SECTION BANK_2
        org     CRT_ORG_BANK_2
        SECTION CODE_2
        SECTION RODATA_2
        SECTION	DATA_2
        SECTION	BSS_2
        SECTION BANK_2_END

        SECTION BANK_3
        org     CRT_ORG_BANK_3
        SECTION CODE_3
        SECTION RODATA_3
        SECTION	DATA_3
        SECTION	BSS_3
        SECTION BANK_3_END

        SECTION BANK_4
        org     CRT_ORG_BANK_4
        SECTION CODE_4
        SECTION RODATA_4
        SECTION	DATA_4
        SECTION	BSS_4
        SECTION BANK_4_END

        SECTION BANK_5
        org     CRT_ORG_BANK_5
        SECTION CODE_5
        SECTION RODATA_5
        SECTION	DATA_5
        SECTION	BSS_5
        SECTION BANK_5_END

        SECTION BANK_6
        org     CRT_ORG_BANK_6
        SECTION CODE_6
        SECTION RODATA_6
        SECTION	DATA_6
        SECTION	BSS_6
        SECTION BANK_6_END

        SECTION BANK_7
        org     CRT_ORG_BANK_7
        SECTION CODE_7
        SECTION RODATA_7
        SECTION	DATA_7
        SECTION	BSS_7
        SECTION BANK_7_END

