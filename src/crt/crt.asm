        include "zcc_opt.def"

        EXTERN  _main

        SECTION BANK_5
        org     CRT_ORG_BANK_5
        SECTION CODE_5
crt0:
        di
		;
		; Setup a stack for the loader
		;
        ld      sp, REGISTER_SP
        jp      _main

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   		; Define Memory Banks
   		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IFDEF   CRT_ORG_BANK_5
        SECTION BANK_5
;        org     CRT_ORG_BANK_5
        SECTION CODE_5
        SECTION RODATA_5
        SECTION DATA_5
        SECTION BSS_5
        SECTION HEAP_5
ENDIF

IFDEF   CRT_ORG_BANK_0
        SECTION BANK_0
        org     CRT_ORG_BANK_0
        SECTION CODE_0
        SECTION RODATA_0
        SECTION DATA_0
        SECTION BSS_0
        SECTION HEAP_0
ENDIF

IFDEF   CRT_ORG_BANK_1
        SECTION BANK_1
        org     CRT_ORG_BANK_1
        SECTION CODE_1
        SECTION RODATA_1
        SECTION DATA_1
        SECTION BSS_1
        SECTION HEAP_1
ENDIF

IFDEF   CRT_ORG_BANK_2
        SECTION BANK_2
        org     CRT_ORG_BANK_2
        ds      0x101, 0x81             ; 257 byte vector table
        ds      0x80, 0x55              ; 128 bytes of stack
        extern  isr
        jp      isr                     ; ISR
        SECTION CODE_2
        SECTION code_clib
        SECTION code_l_sccz80
        SECTION RODATA_2
        SECTION DATA_2
        SECTION BSS_2
        SECTION HEAP_2
ENDIF

IFDEF   CRT_ORG_BANK_3
        SECTION BANK_3
        org     CRT_ORG_BANK_3
        SECTION CODE_3
        SECTION RODATA_3
        SECTION DATA_3
        SECTION BSS_3
        SECTION HEAP_3
ENDIF

IFDEF   CRT_ORG_BANK_4
        SECTION BANK_4
        org     CRT_ORG_BANK_4
        SECTION CODE_4
        SECTION RODATA_4
        SECTION DATA_4
        SECTION BSS_4
        SECTION HEAP_4
ENDIF

IFDEF   CRT_ORG_BANK_6
        SECTION BANK_6
        org     CRT_ORG_BANK_6
        SECTION CODE_6
        SECTION RODATA_6
        SECTION DATA_6
        SECTION BSS_6
        SECTION HEAP_6
ENDIF

IFDEF   CRT_ORG_BANK_7
        SECTION BANK_7
        org     CRT_ORG_BANK_7
        SECTION CODE_7
        SECTION RODATA_7
        SECTION DATA_7
        SECTION BSS_7
        SECTION HEAP_7
ENDIF
