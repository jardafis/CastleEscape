        include "zcc_opt.def"

        EXTERN  _main
        EXTERN  currentBank

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
        EXTERN  __BANK_0_head
        EXTERN  __BANK_1_head
        EXTERN  __BANK_2_head
        EXTERN  __BANK_3_head
        EXTERN  __BANK_4_head
        EXTERN  __BANK_5_head
        EXTERN  __BANK_6_head
        EXTERN  __BANK_7_head

        DEFC    IO_BORDER=0xfe
        DEFC    IO_BANK=0x7ffd
        DEFC    MEM_BANK_ROM=0x10
        DEFC    SCREEN_ATTR_START=0x5800
        DEFC    SCREEN_ATTR_LENGTH=0x300

IFNDEF  CRT_INITIALIZE_BSS
        DEFC    CRT_INITIALIZE_BSS=1
ENDIF
IFNDEF  CRT_CUSTOM_LOADER
        DEFC    CRT_CUSTOM_LOADER=0
ENDIF
IFNDEF  CRT_FILL_STACK
        DEFC    CRT_FILL_STACK=0
ENDIF
IFNDEF  CRT_BORDER_COLOR
        DEFC    CRT_BORDER_COLOR=0
ENDIF
IFNDEF  CRT_SCREEN_ATTRIB
        DEFC    CRT_SCREEN_ATTRIB=0
ENDIF

        PUBLIC  crt0
        PUBLIC  crt0_end

        SECTION CODE
        ORG     CRT_ORG_CODE
crt0:
        di
		;
		; Setup a stack for the loader
		;
        ld      sp, REGISTER_SP

		; Set border to black; MIC output off
        ld      a, CRT_BORDER_COLOR|8
        out     (IO_BORDER), a
		; Color screen
        ld      hl, SCREEN_ATTR_START
        ld      de, SCREEN_ATTR_START+1
        ld      bc, SCREEN_ATTR_LENGTH-1
        ld      (hl), CRT_SCREEN_ATTRIB
        ldir

        call    loadBanks

IF  CRT_INITIALIZE_BSS
        call    bssInit
ENDIF

        ;
        ; Fill the stack with a known pattern so
        ; we can see how much we are using.
        ;
        ; Interrupts should be disabled so no need to worry
        ; about ISR accessing the stack.
        ;
IF  CRT_FILL_STACK
fillStack:
        ld      de, 0x5555              ; Word to fill
        ld      b, CRT_STACK_SIZE/2     ; Stack size in words
fillStackLoop:
        push    de                      ; Push data to stack
        djnz    fillStackLoop           ; Loop for all words
        ld      sp, REGISTER_SP
ENDIF

        ;
        ; Ensure memory bank 0 is paged into 0xc000
        ;
        ld      a, MEM_BANK_ROM|0
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

        jp      _main

loadBanks:
        ld      hl, bankTable
loadNextBank:
        ld      e, (hl)                 ; Read the bank start address
        inc     hl                      ; from the bank table.
        ld      d, (hl)                 ; Low order byte first.
        inc     hl

        ld      a, d                    ; If the bank start address
        or      e                       ; is zero we have reached the end
        ret     z                       ; of the table.

        push    de                      ; Put the start address into
        pop     ix                      ; ix

        ld      e, (hl)                 ; Read the bank length
        inc     hl                      ; from the bank table
        ld      d, (hl)                 ; Low order byte first.
        inc     hl

        ld      c, (hl)                 ; Read the bank #
        inc     hl

        ld      a, d                    ; If the length is 0
        or      e                       ; skip loading the bank
        jr      z, loadNextBank

        ld      a, c
        ld      bc, IO_BANK             ; Switch bank
        out     (c), a

        push    hl                      ; Save the table pointer.

IF  CRT_CUSTOM_LOADER
        call    LD_BYTES
ELSE
        ld      a, 0xff
        scf
        call    0x556
        di                              ; Ensure interrupts are disabled
ENDIF

        pop     hl                      ; Restore the table pointer.
        jr      loadNextBank            ; On to the next bank.

IF  CRT_INITIALIZE_BSS
		;
		; Clear the BSS sections
		;
bssInit:
        ld      hl, bssTable
nextBSSSection:
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        inc     hl

        ld      a, d                    ; If the start address is
        or      e                       ; 0x0000 it's the end of
        ret     z                       ; the BSS table.

        ld      a, (hl)                 ; Get the bank
        inc     hl

		; Switch memory banks
        ld      bc, IO_BANK
        out     (c), a

        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl

        ld      a, b                    ; If the BSS size
        or      c                       ; is zero, skip to the
        jr      z, nextBSSSection       ; next BSS section in the table.

        push    hl
        ex      de, hl

        ld      (hl), 0                 ; Zero first byte of BSS.
        dec     bc                      ; Decrement counter.
        ld      a, b
        or      c
        jr      z, sectionDone          ; If counter is 0, next section in table.

        ld      de, hl
        inc     de                      ; DE = HL + 1.
        ldir                            ; Do the fill.

sectionDone:
        pop     hl
        jr      nextBSSSection

ENDIF
IF  CRT_CUSTOM_LOADER
        include "ld_bytes.asm"
ENDIF

        SECTION RODATA
bssTable:
IFDEF   CRT_ORG_BANK_0
        dw      __BSS_0_head
        db      MEM_BANK_ROM|0
        dw      __BSS_0_tail-__BSS_0_head
ENDIF
IFDEF   CRT_ORG_BANK_1
        dw      __BSS_1_head
        db      MEM_BANK_ROM|1
        dw      __BSS_1_tail-__BSS_1_head
ENDIF
IFDEF   CRT_ORG_BANK_2
        dw      __BSS_2_head
        db      MEM_BANK_ROM|2
        dw      __BSS_2_tail-__BSS_2_head
ENDIF
IFDEF   CRT_ORG_BANK_3
        dw      __BSS_3_head
        db      MEM_BANK_ROM|3
        dw      __BSS_3_tail-__BSS_3_head
ENDIF
IFDEF   CRT_ORG_BANK_4
        dw      __BSS_4_head
        db      MEM_BANK_ROM|4
        dw      __BSS_4_tail-__BSS_4_head
ENDIF
IFDEF   CRT_ORG_BANK_5
        dw      __BSS_5_head
        db      MEM_BANK_ROM|5
        dw      __BSS_5_tail-__BSS_5_head
ENDIF
IFDEF   CRT_ORG_BANK_6
        dw      __BSS_6_head
        db      MEM_BANK_ROM|6
        dw      __BSS_6_tail-__BSS_6_head
ENDIF
IFDEF   CRT_ORG_BANK_7
        dw      __BSS_7_head
        db      MEM_BANK_ROM|7
        dw      __BSS_7_tail-__BSS_7_head
ENDIF
        dw      0x0000
bankTable:
		;
		; Bank 5 is always loaded first because it should
		; include the screen$
		;
IFDEF   CRT_ORG_BANK_5
        dw      __BANK_5_head
        dw      __BSS_5_head-__BANK_5_head
        db      MEM_BANK_ROM|0x5
ENDIF
IFDEF   CRT_ORG_BANK_0
        dw      __BANK_0_head
        dw      __BSS_0_head-__BANK_0_head
        db      MEM_BANK_ROM|0x0
ENDIF
IFDEF   CRT_ORG_BANK_1
        dw      __BANK_1_head
        dw      __BSS_1_head-__BANK_1_head
        db      MEM_BANK_ROM|0x1
ENDIF
IFDEF   CRT_ORG_BANK_2
        dw      __BANK_2_head
        dw      __BSS_2_head-__BANK_2_head
        db      MEM_BANK_ROM|0x2
ENDIF
IFDEF   CRT_ORG_BANK_3
        dw      __BANK_3_head
        dw      __BSS_3_head-__BANK_3_head
        db      MEM_BANK_ROM|0x3
ENDIF
IFDEF   CRT_ORG_BANK_4
        dw      __BANK_4_head
        dw      __BSS_4_head-__BANK_4_head
        db      MEM_BANK_ROM|0x4
ENDIF
IFDEF   CRT_ORG_BANK_6
        dw      __BANK_6_head
        dw      __BSS_6_head-__BANK_6_head
        db      MEM_BANK_ROM|0x6
ENDIF
IFDEF   CRT_ORG_BANK_7
        dw      __BANK_7_head
        dw      __BSS_7_head-__BANK_7_head
        db      MEM_BANK_ROM|0x7
ENDIF
        dw      0x0000
crt0_end:

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
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_1
        SECTION BANK_1
        org     CRT_ORG_BANK_1
        SECTION CODE_1
        SECTION RODATA_1
        SECTION DATA_1
        SECTION BSS_1
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_2
        SECTION BANK_2
        org     CRT_ORG_BANK_2
        SECTION code_clib
        SECTION code_l_sccz80
        SECTION CODE_2
        SECTION RODATA_2
        SECTION DATA_2
        SECTION BSS_2
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_3
        SECTION BANK_3
        org     CRT_ORG_BANK_3
        SECTION CODE_3
        SECTION RODATA_3
        SECTION DATA_3
        SECTION BSS_3
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_4
        SECTION BANK_4
        org     CRT_ORG_BANK_4
        SECTION CODE_4
        SECTION RODATA_4
        SECTION DATA_4
        SECTION BSS_4
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_5
        SECTION BANK_5
        org     CRT_ORG_BANK_5
        SECTION CODE_5
        SECTION RODATA_5
        SECTION DATA_5
        SECTION BSS_5
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_6
        SECTION BANK_6
        org     CRT_ORG_BANK_6
        SECTION CODE_6
        SECTION RODATA_6
        SECTION DATA_6
        SECTION BSS_6
        org     -1
ENDIF

IFDEF   CRT_ORG_BANK_7
        SECTION BANK_7
        org     CRT_ORG_BANK_7
        SECTION CODE_7
        SECTION RODATA_7
        SECTION DATA_7
        SECTION BSS_7
        org     -1
ENDIF
