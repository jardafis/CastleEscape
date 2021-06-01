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

        section code_crt_init
        call    _bankedtapeloader

        section code_driver

        defc    SV_BANKM=currentBank

        include "defs.inc"

        public  _bankedtapeloader
        ;
        ; Does not load the BSS sections. It is expected crt0 zeros these out.
        ; Disabled interrupts before exit.
        ;
_bankedtapeloader:
        ld      ix, __BANK_0_head
        ld      de, __BSS_0_head-__BANK_0_head
        ld      c, MEM_BANK_ROM|0x0     ; Bank 0
        call    load_block
        ret     c
        ld      ix, __BANK_1_head
        ld      de, __BSS_1_head-__BANK_1_head
        ld      c, MEM_BANK_ROM|0x1     ;Bank 1
        call    load_block
        ret     c
        ld      ix, __BANK_2_head
        ld      de, __BSS_2_head-__BANK_2_head
        ld      c, MEM_BANK_ROM|0x2     ;Bank 2
        call    load_block
        ret     c
        ld      ix, __BANK_3_head
        ld      de, __BSS_3_head-__BANK_3_head
        ld      c, MEM_BANK_ROM|0x3     ;Bank 3
        call    load_block
        ret     c
        ld      ix, __BANK_4_head
        ld      de, __BSS_4_head-__BANK_4_head
        ld      c, MEM_BANK_ROM|0x4     ;Bank 4
        call    load_block
        ret     c
        ld      ix, __BANK_5_head
        ld      de, __BSS_5_head-__BANK_5_head
        ld      c, MEM_BANK_ROM|0x5     ;Bank 5
        call    load_block
        ret     c
        ld      ix, __BANK_6_head
        ld      de, __BSS_6_head-__BANK_6_head
        ld      c, MEM_BANK_ROM|0x6     ;Bank 6
        call    load_block
        ret     c
        ld      ix, __BANK_7_head
        ld      de, __BSS_7_head-__BANK_7_head
        ld      c, MEM_BANK_ROM|0x7     ;Bank 7
        call    load_block
        ld      a, MEM_BANK_ROM|0x0     ; Bank 0
        ld      (SV_BANKM), a
        ld      bc, IO_BANK
        out     (c), a
        di								; The call to ROM peaves interrupts enabled. Disable them.
        ret

load_block:
        ld      a, d
        or      e
        ret     z                       ;Nothing to load
        ld      a, c
        ld      (SV_BANKM), a
        ld      bc, IO_BANK
        out     (c), a
        ld      a, 255                  ;Data block
        scf                             ;Load
        call    0x556                   ; call the tape loader in ROM
        and     a
        ret
