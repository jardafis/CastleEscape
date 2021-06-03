        extern  addBCD
        extern  display2BCD
        extern  START_SOUND
        extern  removeItem

        public  heartCount
        public  currentHeartTable
        public  heartTables
        public  hearts
        public  heartCollision

        include "defs.inc"

        section CODE
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
        call    START_SOUND
        ret

        section BSS
heartCount:                             ; BCD
        ds      2

currentHeartTable:
        ds      2

heartTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

hearts:
        ds      SIZEOF_item*MAX_HEARTS*MAX_LEVEL_X*MAX_LEVEL_Y
