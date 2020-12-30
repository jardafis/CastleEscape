		public	_lanternFlicker
		include	"defs.asm"

		section	code_user

_lanternFlicker:
		push	af
		push	bc
		push	de
		push	hl

		ld		hl,lanterns				; Pointer to table of lanterns

		ld		b,(hl)					; Number of lanterns
		inc		hl
.loop
		ld		e,(hl)					; Get low byte of address
		inc		hl
		ld		d,(hl)					; Get high byte of address
		inc		hl

		push	hl						; Save lantern pointer
		; HL is the pointer to the attribute memory

		ld		a,(toggle)
		inc		a
		ld		(toggle),a
		and		0x03					; Bottom 2 bits are index into color table

		ld		hl,colors				; Pointer to color table
		add		a,l						; 'colors' address is aligned by 4 so add it to 'a'
		ld		l,a						; 'hl' now points to our color attribute

		ld		a,(hl)					; Read attribute
		ld		(de),a					; and write it to the screen

		pop		hl						; Restore lantern pointer
		djnz	loop

		pop		hl
		pop		de
		pop		bc
		pop		af
		ret

		section bss_user
.toggle
		db		0

		section rodata_user
		ds		$ - ($ & 0x03) + 0x03, 0x55	; Align by 4
.colors
		db		INK_YELLOW | BRIGHT, INK_YELLOW, INK_RED, INK_RED | BRIGHT

.lanterns	;   y,x
		db		3						; Num lanterns
		dw		SCREEN_ATTR_START + (16 * SCREEN_WIDTH) + 15
		dw		SCREEN_ATTR_START + (8 * SCREEN_WIDTH) + 21
		dw		SCREEN_ATTR_START + (16 * SCREEN_WIDTH) + 28
