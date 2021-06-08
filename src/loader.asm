        EXTERN  crt0
        EXTERN  crt0_end
        SECTION LOADER
        org     -1
        ld      ix, crt0
        ld      de, crt0_end-crt0
        ld      a, 0xff
        scf
        call    0x556
        jp      crt0
