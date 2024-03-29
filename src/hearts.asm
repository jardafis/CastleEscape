        extern  display2BCD
        extern  incBCD
        extern  removeItem
        extern  wyz_play_sound

        public  currentHeartTable
        public  heartCollision
        public  heartCount
        public  heartTables

        #include    "defs.inc"

        section CODE_2
        ;
        ; Called when a collision is detected
        ;
        ;	Entry:
        ;		hl - Pointer to items flags
        ;		b  - Screen y character position
        ;		c  - screen x character position
        ;
heartCollision:
        call    removeItem              ; Remove the item from the screen

        ld      de, heartCount
        call    incBCD

        ld      bc, 0x011d              ; y,x screen location
        ex      de, hl
        call    display2BCD

        di
        ld      a, AYFX_COLLECT_HEART   ; Play a sound
        ld      b, AYFX_CHANNEL
        call    wyz_play_sound
        ei
        ret

        section BSS_2
heartCount:                             ; BCD
        ds      2

currentHeartTable:
        ds      2

heartTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

