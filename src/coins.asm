        extern  addBCD
        extern  _displayScore
        extern  score
        extern  wyz_play_sound
        extern  removeItem
        extern  displayTilePixel

        public  _animateCoins
        public  _coinTables
        public  coins
        public  currentCoinTable
        public  coinCollision

        include "defs.inc"

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
        ; Calculate the tile using the animation index
        ld      a, (hl)                 ; Animation index
        inc     a
        ld      (hl), a
        inc     hl
        and     0x03                    ; Only 4 animations 0-3
        add     ID_COIN                 ; Index of first animation

        call    displayTilePixel

        jp      nextCoin
notVisible:
        ld      a, SIZEOF_item
        addhl
        jp      nextCoin

        ;
        ; Add 5 to the score and display it
        ;
coinCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, COIN_POINTS
        ld      de, score
        call    addBCD
        call    _displayScore
        ld      a, AYFX_COLLECT_COIN
        call    wyz_play_sound
        ret

        section BSS_2

currentCoinTable:
        ds      2

_coinTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

coins:
        ds      SIZEOF_item*MAX_COINS*MAX_LEVEL_X*MAX_LEVEL_Y
