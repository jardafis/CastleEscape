        include "defs.inc"

        extern  wyz_play_frame
        extern  __VECTORS_head

        public  initISR
        public  ticks
        public  isr

        section CODE_5
initISR:
        di
        ld      a, __VECTORS_head>>8    ; Write the high order byte of the
        ld      i, a                    ; vector table address to the i register
        im      2                       ; Enable interrupt mode 2
        ei                              ; Enable interrupts
        ret

        section ISR
isr:
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        push    iy

IFDEF   SOUND
        call    wyz_play_frame
ENDIF

        ;
        ; Increment tick count
        ;
        ld      hl, ticks
nextByte:
        inc     (hl)
        inc     hl
        jr      z, nextByte

        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af                      ; Restore the registers we used
        ei                              ; Enable interrupts
        reti                            ; Acknowledge and return from interrupt

        section BSS_2
ticks:
        ds      5                       ; 40-bits incremented every 1/50 second
                                        ; ~697 years before it wraps and clobbers
                                        ; something. Should be enough ;)
