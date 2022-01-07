        extern  addBCD
        extern  display4BCD
        extern  displayTile
        extern  removeItem
        extern  score
        extern  wyz_play_sound

        public  _animateCoins
        public  _coinTables
        public  coinCollision
        public  currentCoinTable

        #include    "defs.inc"

        section CODE_2

        ;
        ; Animate the visible coins on the current level.
        ;
_animateCoins:
        ld      hl, (currentCoinTable)
nextCoin:
        ld      a, (hl)                 ; Coin flags
        or      a                       ; Update flags based on the value of 'a'
        ret     m                       ; Bit-7 set means end of table
        jp      z, notVisible           ; Zero means not visible

        inc     hl
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl

        pixelToChar b, c

        ; Calculate the tile using the animation index
        ld      a, (hl)                 ; Animation index
        inc     a
        ld      (hl), a
        inc     hl
        and     0x03                    ; Only 4 animations 0-3
        add     ID_COIN                 ; Index of first animation

        call    displayTile

        jp      nextCoin
notVisible:
        addhl   SIZEOF_item
        jp      nextCoin

        ;
        ; Called when a collision is detected
        ;
        ;	Entry:
        ;		hl - Pointer to items flags
        ;		b  - Screen y character position
        ;		c  - screen x character position
        ;
coinCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, COIN_POINTS          ; Add points
        ld      de, score
        call    addBCD

        ex      de, hl
        ld      bc, 0x0103              ; Y/X screen location
        call    display4BCD

        ld      a, AYFX_COLLECT_COIN    ; Play a sound
        ld      b, 2                    ; Use channel #2
        di
        call    wyz_play_sound
        ei
        ret

        section BSS_2

currentCoinTable:
        ds      2

_coinTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

