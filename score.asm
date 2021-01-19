        extern  display2BCD

        public  _displayScore
        public  score

        include "defs.asm"
        section code_user

        ;
        ; Display the current score
        ;
_displayScore:
        push    bc
        push    hl

        ld      bc,0x0301               ; x,y screen location
        ld      hl,score+1              ; Point to 1000's/100's of score
        call    display2BCD
        ld      bc,0x0501               ; x,y screen location
        ld      hl,score                ; Point to 10's/1's of score
        call    display2BCD

        pop     hl
        pop     bc
        ret     

        section bss_user
score:                                  ; Score in BCD
        dw      0x0000
