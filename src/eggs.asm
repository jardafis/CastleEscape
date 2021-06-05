        extern  displayBCD
        extern  addBCD
        extern  displayTile
        extern  decBCD
        extern  START_SOUND
        extern  removeItem

        public  eggTables
        public  eggs
        public  currentEggTable
        public  eggCollision
        public  eggCount
        public  updateEggImage
        public  decrementEggs
        public  displayEggCount

        include "defs.inc"

        section CODE_2
        ;
        ; Increment and display the egg count
        ;
eggCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, 0x10
        ld      de, eggCount
        call    addBCD
        call    displayEggCount
        ld      a, AYFX_COLLECT_EGG
        call    START_SOUND
        ret

updateEggImage:
        ld      a, (eggCount)
        rrca                            ; divide by 2
        and     %00000111
        add     ID_EGG0
        ld      bc, 0x011a
        call    displayTile
        ret

decrementEggs:
        push    hl

        ld      hl, counter
        dec     (hl)
        jp      p, skip
        ld      (hl), 99

        push    af

        ld      a, (eggCount)
        and     a
        jr      z, noEggs

        push    de

        ld      de, eggCount
        call    decBCD
        call    displayEggCount

        pop     de

noEggs:
        pop     af
skip:
        pop     hl
        ret

displayEggCount:
        push    bc
        ld      bc, 0x0119              ; Y/X screen location
        ld      a, (eggCount)
        rrca
        rrca
        rrca
        rrca
        and     %00001111
        call    displayBCD
        call    updateEggImage
        pop     bc
        ret

        section BSS_2
counter:
        ds      1
eggCount:                               ; BCD
        ds      2

currentEggTable:
        ds      2

eggTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

eggs:
        ds      SIZEOF_item*MAX_EGGS*MAX_LEVEL_X*MAX_LEVEL_Y
