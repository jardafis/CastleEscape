        extern  wyz_play_frame

        public  initISR
        public  ticks
        public  isr
        section CODE_2

        include "defs.inc"
        defc    VECTOR_TABLE_HIGH=0x80

initISR:
        push    af

        ld      a, VECTOR_TABLE_HIGH    ; Write the address of the vector table
        ld      i, a                    ; to the i register
        im      2                       ; Enable interrupt mode 2
        ei                              ; Enable interrupts

        pop     af
        ret

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
        ds      5                       ; 48-bits incremented every 1/50 second
                                        ; ~178000 years before it wraps and clobbers
                                        ; something. Should be enough ;)
