        extern  _displayBCD
        public  _displayScore
        public	score

        include "defs.asm"
        section code_user

        ;
        ; Display the current score
        ;
_displayScore:
        push    af
        push    bc
        push    hl

        ld      bc,0x0301               ; x,y screen location
        ld      hl,score+1              ; Point to 1000's/100's of score
        xor     a                       ; Zero a

        rld                             ; Get high order nibble from (hl)
        call    _displayBCD             ; Display the character
        inc     b                       ; Increment x screen location
        rld                             ; Get low order nibble from (hl)
        call    _displayBCD
        inc     b                       ; Increment x screen location
        rld                             ; Put the low order nibble back in (hl)

        dec     hl                      ; Point to 100's and units

        rld                             ; Get high order nibble from (hl)
        call    _displayBCD             ; Display the character
        inc     b                       ; Increment x screen location
        rld                             ; Get low order nibble from (hl)
        call    _displayBCD
        rld                             ; Put the low order nibble back in (hl)

        pop     hl
        pop     bc
        pop     af
        ret     

        section bss_user
score:                                  ; Score in BCD
        dw      0x0000
