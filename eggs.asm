		extern	_xPos
		extern	_yPos
		extern	_addScore
		extern	_displayScore
		extern	clearAttr
		extern	clearChar

		public	eggTables
		public	eggs
		public	currentEggTable
		public	checkEggCollision

        include "defs.asm"

		defc	EGG_HEIGHT		= 0x07
		defc	EGG_WIDTH		= 0x08

		section	code_user

		;
		; Check if the player has collided with a coin. And if so,
		; remove the coin from the level and increase and re-display
		; the score.
		;
checkEggCollision:
		ld		hl,(currentEggTable)
.nextEgg
		ld		a,(hl)
        cp      0xff
        ret		z

        cp      0x00                    ; Is the item visible?
        jr      z,notVisible

		push	hl
		inc		hl

		;
		; Collision check here
		;
		ld		a,(hl)					; X byte position
		rlca							; x2
		rlca							; x4
		rlca							; x8
		and		%11111000				; Left side pixel offset
		ld		b,a
		add		EGG_WIDTH-1				; Right side pixel offset
		ld		c,a

		ld		a,(_xPos)				; Player left side pixel position
		inc		a
		cp		c						; Compare with coin right side
		jr		nc,blah					; 'nc' if 'c' <= 'a'

		add		PLAYER_WIDTH-4			; Get right side pixel position
		cp		b						; Compare with coin left side
		jr		c,blah					; 'c' if 'b' > 'a'

		inc		hl
		ld		a,(hl)					; Y byte position
		rlca							; x2
		rlca							; x4
		rlca							; x8
		and		%11111000
		ld		b,a						; Top pixel position
		add		EGG_HEIGHT-1			; Bottom pixel offset
		ld		c,a

		ld		a,(_yPos)
		cp		c						; Compare with bottom
		jr		nc,blah					; 'nc' if 'c' <= 'a'

		add		PLAYER_HEIGHT-1			; Player bottom pixel position
		cp		b						; Compare with top
		jr		c,blah					; 'c' if 'b' > 'a'

		ld		b,(hl)					; Y position
		dec		hl						; Back to the flags
		ld		c,(hl)					; X position
		dec		hl
		xor		a						; Zero flags
		ld		(hl),a

		push	bc
		call	clearAttr
		pop		bc
		call	clearChar

		;
		; Add 5 to the score and display it
		;
		ld		l,0x10
		call	_addScore
		call	_displayScore
.blah
		pop		hl
.notVisible
        ld      a,SIZEOF_item
        addhl
        jp      nextEgg


        section bss_user
.currentEggTable	dw		0

eggTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

eggs:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
