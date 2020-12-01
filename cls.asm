	PUBLIC	_cls
	SECTION	code_compiler

	defc SCREEN_START	= 0x4000
	defc SCREEN_LENGTH	= 0x1800
	defc SCREEN_ATTR_START	= (SCREEN_START + SCREEN_LENGTH)
	defc SCREEN_ATTR_LENGTH = 0x300

	;
	; Clear the screen bitmap and attr data.
	;
	; On entry, l contains the attribute to fill the attr memory.
	;
_cls:
	push	bc
	push	de
	push	hl

	di
	ld	(tempSP),sp

	ld	sp,SCREEN_START+SCREEN_LENGTH
	ld	de,0	; data to fill
	; If we devide the screen length by 32 it will
	; fit in 8 bits and we can use djnz
	ld	b,SCREEN_LENGTH/32
.loop
	; Push 32 bytes of 0 into the screen memory
	; Each push is 2 bytes
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	push de
	djnz loop

	ld	sp,SCREEN_ATTR_START+SCREEN_ATTR_LENGTH
	ld	h,l	; attr input parameter in l
	; If we devide the attr length by 4 it will
	; fit in 8 bits and we can use djnz
	ld	b,SCREEN_ATTR_LENGTH/4
.loop2
	; Push 4 bytes of 0 into the screen memory
	; Each push is 2 bytes
	push hl
	push hl
	djnz	loop2

	ld	sp,(tempSP)
	ei

	pop	hl
	pop	de
	pop	bc
	ret

	SECTION	bss_compiler
tempSP:
	dw	0
