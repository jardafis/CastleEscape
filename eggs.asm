        extern  display2BCD
        extern  addBCD

        public  eggTables
        public  eggs
        public  currentEggTable
        public  eggCollision
        public  eggCount

        include "defs.asm"

        section code_user
        ;
        ; Increment and display the egg count
        ;
eggCollision:
        ld      l,0x01
        ld      de,eggCount
        call    addBCD
        ld      bc,0x1a01               ; x,y screen location
        ld      hl,eggCount             ; Point to 1000's/100's of score
        call    display2BCD
        ret     

        section bss_user
eggCount:                               ; BCD
        dw      0x0000

currentEggTable:
        dw      0

eggTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

eggs:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
