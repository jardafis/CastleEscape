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

IFNDEF  CRT_INITIALIZE_BSS
        DEFC    CRT_INITIALIZE_BSS=1
ENDIF

        SECTION CODE
        ORG     CRT_ORG_CODE
crt0:
        di
		;
		; Setup a stack for the loader
		;
        ld      sp, loaderStack

		; Set border to black
        xor     a
        out     (IO_BORDER), a
		; Color screen black
        ld      hl, SCREEN_ATTR_START
        ld      de, SCREEN_ATTR_START+1
        ld      (hl), 0
        ldir

        call    loadBanks

        ;
        ; Ensure memory bank is paged into 0xc000
        ;
        ld      a, 0x10
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

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
        ld      sp, REGISTER_SP
fillStack:
        ld      de, 0x5555              ; Word to fill
        ld      b, CRT_STACK_SIZE/2     ; Stack size in words
fillStackLoop:
        push    de                      ; Push data to stack
        djnz    fillStackLoop           ; Loop for all words
        ld      sp, REGISTER_SP

        jp      _main

        ;
        ; Must disabled interrupts before exit.
        ;
loadBanks:
        ld      hl, bankTable
loadNextBank:
        ld      e, (hl)                 ; Read the bank start address
        inc     hl                      ; from the bank table.
        ld      d, (hl)                 ; Low order byte first.
        inc     hl

        ld      a, d                    ; If the bank start address
        or      e                       ; is zero we have reached the end
        jr      z, banksLoaded          ; of the table. All loading done.

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

        ld      a, 0xff                 ; Data block
        scf                             ; Load
        call    0x556                   ; Call the tape loader in ROM

        pop     hl                      ; Restore the table pointer.
        jr      loadNextBank            ; On to the next bank.
banksLoaded:
        di
        ret

IF  CRT_INITIALIZE_BSS
		;
		; Clear the BSS sections
		;
bssInit:
        ld      (bssInitDone+1), sp
        ld      sp, bssTable
nextBSSSection:
        pop     hl                      ; Get BSS start address.
        ld      a, h                    ; If the start address is
        or      l                       ; 0x0000 it's the end of
        jr      z, bssInitDone          ; the BSS table.

		; Switch memory banks
        pop     af                      ; Get the bank
        ld      bc, 0x7ffd
        out     (c), a

        pop     bc                      ; Get BSS size.
        ld      a, b                    ; If the BSS size
        or      c                       ; is zero, skip to the
        jr      z, nextBSSSection       ; next BSS section in the table.

        ld      (hl), 0                 ; Zero first byte of BSS.
        dec     bc                      ; Decrement counter.
        ld      a, b
        or      c
        jr      z, nextBSSSection       ; If counter is 0, next section in table.

        ld      de, hl
        inc     de                      ; DE = HL + 1.
        ldir                            ; Do the fill.
        jr      nextBSSSection
bssInitDone:
        ld      sp, 0xffff
        ret
ENDIF

        SECTION RODATA
bssTable:
IFDEF   CRT_ORG_BANK_0
        dw      __BSS_0_head
        dw      0x10<<8
        dw      __BSS_0_tail-__BSS_0_head
ENDIF
IFDEF   CRT_ORG_BANK_1
        dw      __BSS_1_head
        dw      0x11<<8
        dw      __BSS_1_tail-__BSS_1_head
ENDIF
IFDEF   CRT_ORG_BANK_2
        dw      __BSS_2_head
        dw      0x12<<8
        dw      __BSS_2_tail-__BSS_2_head
ENDIF
IFDEF   CRT_ORG_BANK_3
        dw      __BSS_3_head
        dw      0x13<<8
        dw      __BSS_3_tail-__BSS_3_head
ENDIF
IFDEF   CRT_ORG_BANK_4
        dw      __BSS_4_head
        dw      0x14<<8
        dw      __BSS_4_tail-__BSS_4_head
ENDIF
IFDEF   CRT_ORG_BANK_5
        dw      __BSS_5_head
        dw      0x15<<8
        dw      __BSS_5_tail-__BSS_5_head
ENDIF
IFDEF   CRT_ORG_BANK_6
        dw      __BSS_6_head
        dw      0x16<<8
        dw      __BSS_6_tail-__BSS_6_head
ENDIF
IFDEF   CRT_ORG_BANK_7
        dw      __BSS_7_head
        dw      0x17<<8
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

        SECTION BSS
        org     -1
        ds      0x10, 0x55
loaderStack:

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
        SECTION code_crt0_sccz80
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
