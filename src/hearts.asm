        extern  addBCD
        extern  display2BCD
        extern  wyz_play_sound
        extern  removeItem

        public  heartCount
        public  currentHeartTable
        public  heartTables
        public  hearts
        public  heartCollision

        include "defs.inc"

        section CODE_2
        ;
        ; Increment and display the egg count
        ;
heartCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, 0x01
        ld      de, heartCount
        call    addBCD
        ld      bc, 0x011d              ; y,x screen location
        ld      hl, heartCount          ; Point to 1000's/100's of score
        call    display2BCD
        ld      a, AYFX_COLLECT_HEART
        call    wyz_play_sound
        ret

        section BSS_2
heartCount:                             ; BCD
        ds      2

currentHeartTable:
        ds      2

heartTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

hearts:
        ds      SIZEOF_item*MAX_HEARTS*MAX_LEVEL_X*MAX_LEVEL_Y
