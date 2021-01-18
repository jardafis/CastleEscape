		extern	addBCD
		extern	_displayBCD

		public	heartCount
		public	currentHeartTable
		public	heartTables
		public	hearts
		public	heartCollision
		public	displayHeartCount

		include	"defs.asm"

		section	code_user
        ;
        ; Display the current score
        ;
displayHeartCount:
        push    af
        push    bc
        push    hl

        ld      bc,0x1d01               ; x,y screen location
        ld      hl,heartCount           ; Point to 1000's/100's of score
        xor     a                       ; Zero a

        rld                             ; Get high order nibble from (hl)
        call    _displayBCD             ; Display the character
        inc     b                       ; Increment x screen location
        rld                             ; Get low order nibble from (hl)
        call    _displayBCD
        inc     b                       ; Increment x screen location
        rld                             ; Put the low order nibble back in (hl)

        pop     hl
        pop     bc
        pop     af
        ret

		;
		; Increment and display the egg count
		;
heartCollision:
		ld		l,0x01
		ld		de,heartCount
		call	addBCD
		call	displayHeartCount
		ret

        section bss_user
heartCount:                            	; BCD
        dw      0x0000

currentHeartTable:
		dw		0

heartTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

hearts:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
