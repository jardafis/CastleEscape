        extern	_displayBCD
		public	_initScore
		public	_incScore
		public	_addScore
		public	_displayScore

		include	"defs.asm"
		section code_user

		;
		; Initialize the score to zero
		;
_initScore:
		push	hl
		ld		hl,0
		ld		(score),hl
		pop		hl
		ret

		;
		; On entry:
		;		l = BCD value to add to score
		;
_addScore:
		push	af
		push	de

		ld		de,score				; Pointer to the score

		ld		a,(de)					; Get low byte of BCD score
		add		l						; Add the BCD value passed in
		daa								; Adjust result for BCD
		ld		(de),a					; Save the updated score
		jr		c,incUpper				; If c there was wraparound

.addScoreDone
		pop		de
		pop		af
		ret

.incUpper
		inc		de						; There was a wraparound
		ld		a,(de)					; Get high byte of BCD score
		or		a						; Clear the carry flag
		inc		a						; Increment the score
		daa								; Adjust result for BCD
		ld		(de),a					; Save the incremented score
		pop		de
		pop		af
		ret

		;
		; Increment the score by 1
		; The Score is stored in BCD so this is not straight forward
		;
_incScore:
		push	hl

		ld		l,1
		call	_addScore

		pop		hl
		ret

		;
		; Display the current score
		;
_displayScore:
		push	af
		push	bc
		push	hl

		ld		bc,0x0201				; x,y screen location
		ld		hl,score+1				; Point to 1000's/100's of score
		xor		a						; Zero a

		rld								; Get high order nibble from (hl)
		call	_displayBCD				; Display the character
		inc		b						; Increment x screen location
		rld								; Get low order nibble from (hl)
		call	_displayBCD
		inc		b						; Increment x screen location
		rld								; Put the low order nibble back in (hl)

		dec		hl						; Point to 100's and units

		rld								; Get high order nibble from (hl)
		call	_displayBCD				; Display the character
		inc		b						; Increment x screen location
		rld								; Get low order nibble from (hl)
		call	_displayBCD
		rld								; Put the low order nibble back in (hl)

		pop		hl
		pop		bc
		pop		af
		ret

		section bss_user
.score	; Score in BCD
		dw	0x0000
