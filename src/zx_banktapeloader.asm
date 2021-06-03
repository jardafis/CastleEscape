        extern  __BANK_0_head
        extern  __BANK_1_head
        extern  __BANK_2_head
        extern  __BANK_3_head
        extern  __BANK_4_head
        extern  __BANK_5_head
        extern  __BANK_6_head
        extern  __BANK_7_head

        extern  __BSS_0_head
        extern  __BSS_1_head
        extern  __BSS_2_head
        extern  __BSS_3_head
        extern  __BSS_4_head
        extern  __BSS_5_head
        extern  __BSS_6_head
        extern  __BSS_7_head

        section CODE
        include "defs.inc"
        include "zcc_opt.inc"

        public  loadError
loadError:
        assert

        public  bankedtapeloader
        ;
        ; Does not load the BSS sections. It is expected crt0 zeros these out.
        ; Disabled interrupts before exit.
        ;
bankedtapeloader:
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

        push    hl                      ; Save the table pointer.

        call    load_block              ; Call the load subroutine

        pop     hl                      ; Restore the table pointer.
        jr      loadNextBank            ; On to the next bank.
banksLoaded:
        ld      a, MEM_BANK_ROM|0x0     ; Bank 0
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a
        di
        ret

load_block:
        ld      a, d
        or      e
        ret     z                       ; Nothing to load

        ld      a, c                    ; Set the bank
        ld      (currentBank), a
        ld      bc, IO_BANK
        out     (c), a

        ld      a, 0xff                 ; Data block
        scf                             ; Load
        call    0x556                   ; Call the tape loader in ROM

        ld      a, (currentBank)
        call    nc, loadError
        ret

        section RODATA
bankTable:
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
IFDEF   CRT_ORG_BANK_5
        dw      __BANK_5_head
        dw      __BSS_5_head-__BANK_5_head
        db      MEM_BANK_ROM|0x5
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
