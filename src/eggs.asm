        extern  addBCD
        extern  decBCD
        extern  displayBCD
        extern  displayTile
        extern  removeItem
        extern  wyz_play_sound

        public  currentEggTable
        public  decrementEggs
        public  displayEggCount
        public  eggCollision
        public  eggCount
        public  eggTables
        public  eggs
        public  updateEggImage

        include "defs.inc"

        section CODE_2

        ;
        ; Called when a collision is detected
        ;
        ;	Entry:
        ;		hl - Pointer to items flags
        ;		b  - Screen y character position
        ;		c  - screen x character position
        ;
eggCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, 0x10                 ; Add eggs
        ld      de, eggCount
        call    addBCD

        call    displayEggCount

        ld      a, AYFX_COLLECT_EGG     ; Play a sound
        call    wyz_play_sound
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
