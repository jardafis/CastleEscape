        public  _lanternFlicker
        public  _lanternList
        #include    "defs.inc"

        section CODE_2
        ;
        ; On entry:
        ;			hl - Pointer to lantern table
        ;
_lanternFlicker:
        ld      a, (hl)                 ; Number of lanterns
        or      a
        ret     z                       ; No lanterns
        inc     hl                      ; Point to first attribute address

        di
        ld      (tempSP+1), sp          ; Save stack pointer
        ld      sp, hl                  ; Point stack at attribute address table

        ld      b, a                    ; Set loop count
IF  !_ZXN
        ld      hl, colors              ; Pointer to color table
        ld      a, r                    ; Use 'r' as the color table index
        and     0x03                    ; Bottom 2 bits only
        addhl   a
        ld      a, (hl)                 ; Read attribute
ENDIF
loop:
        pop     hl                      ; Pop the attribute address
IF  _ZXN
        ld      a, r
        and     0x03
        add     SPRITE_ID_LANTERN
ENDIF
        ld      (hl), a                 ; and update the attribute value
        djnz    loop                    ; Loop for all lanterns

tempSP:
        ld      sp, -1                  ; Restore the stack
        ei
done:
        ret

IF  !_ZXN
        section RODATA_2
colors:
        db      INK_YELLOW
        db      INK_RED
        db      (INK_YELLOW|BRIGHT)
        db      (INK_RED|BRIGHT)
ENDIF
        section BSS_2
_lanternList:                           ; Max of 8 lanterns on any screen
        ds      SIZEOF_byte
        ds      SIZEOF_ptr*MAX_LANTERNS
