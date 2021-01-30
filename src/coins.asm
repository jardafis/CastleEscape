        extern  _screenTab
        extern  _tile0
        extern  addBCD
        extern  _displayScore
        extern  score
        extern  AFXPLAY

        public  _animateCoins
        public  _coinTables
        public  coins
        public  currentCoinTable
        public  coinCollision

        include "defs.asm"

        section code_user

        ;
        ; Animate the visible coins on the current level.
        ;
_animateCoins:
        ld      hl, (currentCoinTable)
nextCoin:
        ld      a, (hl)                 ; Coin flags
        cp      0xff
        ret     z

        cp      0x00                    ; Is the coin visible?
        jr      z, notVisible
        inc     hl


        ; Calculate the screen address
        ld      c, (hl)                 ; X screen position
        inc     hl
        push    hl                      ; Save coin table pointer

        ld      l, (hl)                 ; Y screen position
        ld      h, 0
        hlx     16
        ld      de, _screenTab
        add     hl, de
        ld      a, (hl)
        add     c                       ; Add X offset
        ld      c, a                    ; Store result in 'c'
        inc     hl
        ld      b, (hl)

        pop     hl                      ; Restore coin table pointer
        inc     hl

        ; Calculate the tile address using the animation index
        ld      a, (hl)                 ; Animation index
        and     0x03                    ; Only 4 animations 0-3
        add     ID_COIN                 ; Index of first animation
        inc     (hl)                    ; Increment animation index for next time
        inc     hl

        push    hl                      ; Save coin table pointer

        ld      l, a
        ld      h, 0
        hlx     8
        ld      de, _tile0
        add     hl, de

        ; Display the tile. We are going to use the
        ; stack pointer to load a 16 bit value so
        ; we need to disable interrupts.
        di      
        ; Save the current stack pointer
        ld      (animateTempSP), sp
        ; Point the stack at the tile data
        ld      sp, hl
        ; Point hl at the screen address
        ld      hl, bc

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl), c                 ; 7
        inc     h                       ; Add 256 to screen address 4
        ld      (hl), b                 ; 7
        inc     h                       ; Add 256 to screen address 4

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b

        ; Restore the stack pointer.
animateTempSP   equ $+1
        ld      sp, 0x0000
        ei      

        pop     hl                      ; Restore coin table pointer
        jp      nextCoin

notVisible:
        ld      a, SIZEOF_item
        addhl   
        jp      nextCoin

        ;
        ; Add 5 to the score and display it
        ;
coinCollision:
        ld      l, 0x05
        ld      de, score
        call    addBCD
        call    _displayScore
        ld      a, AYFX_COLLECT_COIN
        call    AFXPLAY
        ret     

        section bss_user

currentCoinTable:
        dw      0

_coinTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*2

coins:
        ds      SIZEOF_item*8*MAX_LEVEL_X*MAX_LEVEL_Y
