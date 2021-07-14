        extern  display2BCD

        public  _displayScore
        public  score

        include "defs.inc"
        section CODE_2

        ;
        ; Display the current score
        ;
_displayScore:
        push    bc
        push    hl

        ld      bc, 0x0103              ; y,x screen location
        ld      hl, score+1             ; Point to 1000's/100's
        call    display2BCD
        ld      c, 0x05                 ; x screen location
        ld      hl, score               ; Point to 10's/1's
        call    display2BCD

        pop     hl
        pop     bc
        ret

        section BSS_2
score:                                  ; Score in BCD
        ds      2
