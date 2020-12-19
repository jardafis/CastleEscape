        extern  _screenTab
		public	_initScore
		public	_incScore
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
		; Increment the score by 1
		; The Score is stored in BCD so this is not straight forward
		;
_incScore:
		push	af
		push	hl

		ld		hl,score				; Pointer to the score

		ld		a,(hl)					; Get 10's and units
		or		a						; Clear the carry flag
		inc		a						; Increment the score
		daa								; Adjust result for BCD
		ld		(hl),a					; Save the incremented score
		jr		nz,incScoreDone			; If nz there was no wraparound so we are done

		inc		hl						; There was a wraparound
		ld		a,(hl)					; Get 1000's and 100's
		or		a						; Clear the carry flag
		inc		a						; Increment the score
		daa								; Adjust result for BCD
		ld		(hl),a					; Save the incremented score

.incScoreDone
		pop		hl
		pop		af
		ret

		;
		; Display the current score
		;
_displayScore:
		push	af
		push	bc
		push	hl

		ld		bc,0x0204				; x,y screen location
		ld		hl,score+1				; Point to 1000's/100's of score
		xor		a						; Zero a

		rld								; Get high order nibble from (hl)
		call	displayBCD				; Display the character
		inc		b						; Increment x screen location
		rld								; Get low order nibble from (hl)
		call	displayBCD
		inc		b						; Increment x screen location
		rld								; Put the low order nibble back in (hl)

		dec		hl						; Point to 100's and units

		rld								; Get high order nibble from (hl)
		call	displayBCD				; Display the character
		inc		b						; Increment x screen location
		rld								; Get low order nibble from (hl)
		call	displayBCD
		rld								; Put the low order nibble back in (hl)

		pop		hl
		pop		bc
		pop		af
		ret

		; On entry:
		;		a[3:0] = BCD value to display, a[7:4] must be zero
		;		b = X character position
		;		c = y character position
.displayBCD
		push	af
		push	bc
		exx
		ex		af,af'
		pop		bc
		pop		af

		ld		l,a
		ld		h,0
		hlx		8						; x8
		ld		de,ROM_FONT + (('0' - 32) * 8) ; Start address of numbers in font
		add		hl,de					; Pointer to start of character in ROM font
		push	hl						; Save font pointer address


		ld		h,0
		ld		l,c
		hlx		16						; x16
		ld		de,_screenTab
		add		hl,de					; Pointer to screenTab entry

		; Get the screen table entry into de
		ld		a,(hl)
		add		b						; Add x position to low 8 bits of the screen address
		ld		e,a
		inc		hl
		ld		d,(hl)

		pop		hl						; Restore font pointer

		; Display a single digit 0 - 9
		ld		b,8
.numLoop
		ld		a,(hl)
		ld		(de),a
		inc		hl
		inc		d
		djnz	numLoop

		ex		af,af'
		exx
		ret

		section bss_user
.score	; Score in BCD
		dw	0x0000
