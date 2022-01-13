        extern  _main

IFNDEF  CRT_ORG_BANK_5
        defc    CRT_ORG_BANK_5=0x06000
ENDIF

IFNDEF  CRT_ORG_BANK_2
        defc    CRT_ORG_BANK_2=0x08000
ENDIF

IFNDEF  CRT_ORG_BANK_0
        defc    CRT_ORG_BANK_0=0x0c000
ENDIF

IFNDEF  CRT_ORG_BANK_1
        defc    CRT_ORG_BANK_1=0x1c000
ENDIF

IFNDEF  CRT_ORG_BANK_3
        defc    CRT_ORG_BANK_3=0x3c000
ENDIF

IFNDEF  CRT_ORG_BANK_4
        defc    CRT_ORG_BANK_4=0x4c000
ENDIF

IFNDEF  CRT_ORG_BANK_6
        defc    CRT_ORG_BANK_6=0x6c000
ENDIF

IFNDEF  CRT_ORG_BANK_7
        defc    CRT_ORG_BANK_7=0x7c000
ENDIF

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   		; Define Memory Banks
   		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        SECTION VECTORS
        ds      0x101, 0x81             ; 257 byte vector table
        SECTION BANKING_STACK
        ds      0x20, 0xaa              ; 32 bytes of banked call stack
        SECTION STACK
        ds      0x60, 0x55              ; 96 bytes of stack
        SECTION ISR                     ; Interrupt subroutine @ 0x8181
        SECTION code_clib
        SECTION code_l_sccz80
        SECTION dzx0_decompress
        SECTION CODE_2
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

IFDEF   CRT_ORG_BANK_5
        SECTION BANK_5
        org     CRT_ORG_BANK_5
        SECTION CODE_5
        SECTION RODATA_5
        SECTION DATA_5
        SECTION BSS_5
        SECTION HEAP_5
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
