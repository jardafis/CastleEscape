		extern	_xPos
		extern	_yPos
		extern	_addScore
		extern	_displayScore
		extern	clearAttr
		extern	clearChar
		extern	_displayBCD
		extern	addBCD

		public	eggTables
		public	eggs
		public	currentEggTable
		public	eggCollision
		public	displayEggCount
		public	eggCount

        include "defs.asm"

		defc	EGG_HEIGHT		= 0x07
		defc	EGG_WIDTH		= 0x08

		section	code_user
        ;
        ; Display the current score
        ;
displayEggCount:
        push    af
        push    bc
        push    hl

        ld      bc,0x1a01               ; x,y screen location
        ld      hl,eggCount             ; Point to 1000's/100's of score
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
eggCollision:
		ld		l,0x01
		ld		de,eggCount
		call	addBCD
		call	displayEggCount
		ret


        section bss_user
eggCount:                            	; BCD
        dw      0x0000

.currentEggTable	dw		0

eggTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

eggs:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
