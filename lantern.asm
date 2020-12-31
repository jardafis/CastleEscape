		public	_lanternFlicker
		extern	ticks
		include	"defs.asm"

		section	code_user
		;
		; On entry:
		;			hl - Pointer to lantern table
		;
_lanternFlicker:
		push	af

		ld		a,(hl)					; Number of lanterns
		or		a
		jr		z,done					; No lanterns

		push	bc
		push	de
		push	hl

		inc		hl						; Point to first attribute address
		ld		b,a
.loop
		ld		e,(hl)					; Get low byte of address
		inc		hl
		ld		d,(hl)					; Get high byte of address
		inc		hl
		; DE is the pointer to the attribute memory

		ld		a,(ticks)
		and		0x03					; Bottom 2 bits are the index into color table

		push	bc						; Save loop counter
		ld		bc,colors				; Pointer to color table
		add		c						; 'colors' address is aligned by 4 so add it to 'a'
		ld		c,a						; 'hl' now points to our color attribute

		ld		a,(bc)					; Read attribute
		ld		(de),a					; and write it to the screen

		pop		bc						; Restore loop counter
		djnz	loop

		pop		hl
		pop		de
		pop		bc
.done
		pop		af
		ret

		section rodata_user
.colors
		db		(INK_YELLOW | BRIGHT), INK_YELLOW, INK_RED, (INK_RED | BRIGHT)
