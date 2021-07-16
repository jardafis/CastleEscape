        public  _lanternFlicker
        public  _lanternList
        include "defs.inc"

        section CODE_2
        ;
        ; On entry:
        ;			hl - Pointer to lantern table
        ;
_lanternFlicker:
        ld      a, (hl)                 ; Number of lanterns
        or      a
        jr      z, done                 ; No lanterns
        inc     hl                      ; Point to first attribute address

        di
        ld      (tempSP+1), sp          ; Save stack pointer
        ld      sp, hl                  ; Point stack at attribute address table

        ld      b, a                    ; Set loop count

        ld      hl, colors              ; Pointer to color table
        ld      a, r                    ; Use 'r' as the color table index
        and     0x03                    ; Bottom 2 bits only
        addhl
        ld      a, (hl)                 ; Read attribute

loop:
        pop     hl                      ; Pop the attribute address
        ld      (hl), a                 ; and update the attribute value
        djnz    loop                    ; Loop for all lanterns

tempSP:
        ld      sp, -1                  ; Restore the stack
        ei
done:
        ret

        section RODATA_2
colors:
        db      INK_YELLOW
        db      INK_RED
        db      (INK_YELLOW|BRIGHT)
        db      (INK_RED|BRIGHT)

        section BSS_2
_lanternList:                           ; Max of 8 lanterns on any screen
        ds      SIZEOF_byte
        ds      SIZEOF_ptr*MAX_LANTERNS
