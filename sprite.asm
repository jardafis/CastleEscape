		EXTERN _screenTab

		SECTION	code_compiler

		PUBLIC _copyScreen
		PUBLIC _pasteScreen
		PUBLIC _displaySprite

		; On input:
		;	sp + 0 = sprite x position in pixels
		;	sp + 1 = sprite y position in pixels
		;	sp + 2 = pointer to buffer
_copyScreen:
		push	af
		push	de
		push	hl
		push	ix

		ld		ix,10
		add		ix,sp

		di
		ld		(tempsp),sp

		; Claculate the screen Y address
		ld		h,0
		ld		l,(ix+1)	; get the y position	  19
		add		hl,hl		; multiply by 2           11
		ld		sp,_screenTab	;                     10
		add		hl,sp		;                         11
		ld		sp,hl		;						  6


		ld		e,(ix+2)
		ld		d,(ix+3)


		ld		b,8
		ld		c,(ix+0)	; Get the X offset        13
		srl		c			; divide by 8 to get byte address
		srl		c
		srl		c
.copyloop
		pop		hl			; get screen row adress
		ld		a,l
		add		a,c			; add x offset
		ld		l,a

		ld		a,(hl)
		ld		(de),a
		inc		de

		djnz	copyloop

		ld		sp,(tempsp)
		ei

		pop		ix
		pop		hl
		pop		de
		pop		af
		ret

_pasteScreen:
		push	af
		push	de
		push	hl
		push	ix


		ld		ix,10
		add		ix,sp

		di
		ld		(tempsp),sp

		; Claculate the screen Y address
		ld		h,0
		ld		l,(ix+1)	; get the y position	  19
		add		hl,hl		; multiply by 2           11
		ld		sp,_screenTab	;                     10
		add		hl,sp		;                         11
		ld		sp,hl		;						  6


		ld		e,(ix+2)
		ld		d,(ix+3)


		ld		b,8
		ld		c,(ix+0)	; Get the X offset        13
		srl		c			; divide by 8 to get byte address
		srl		c
		srl		c
.pasteloop
		pop		hl			; get screen row adress
		ld		a,l
		add		a,c			; add x offset
		ld		l,a

		ld		a,(de)
		inc		de
		ld		(hl),a

		djnz	pasteloop

		ld		sp,(tempsp)
		ei

		pop		ix
		pop		hl
		pop		de
		pop		af
		ret

_displaySprite:
		push	af
		push	bc
		push	de
		push	hl
		push	ix

		ld		ix,12
		add		ix,sp

		di
		ld		(tempsp),sp

		; Claculate the screen Y address
		ld		h,0
		ld		l,(ix+1)	; get the y position	  16
		add		hl,hl		; multiply by 2           11
		ld		sp,_screenTab	;                     10
		add		hl,sp		;                         11
		ld		sp,hl

		ld		de,sprite

		ld		b,8
		ld		c,(ix+0)	; Get the X offset        13
		srl		c			; divide by 8 to get byte address
		srl		c
		srl		c
.loop1
		pop		hl			; get screen row adress
		ld		a,l
		add		a,c			; add x offset
		ld		l,a

		ld		a,(de)		; mask data
		and		(hl)
		ld		(hl),a
		inc		de

		ld		a,(de)		; sprite data
		or		(hl)
		ld		(hl),a
		inc		de

		djnz	loop1

		ld		sp,(tempsp)
		ei

		pop		ix
		pop		hl
		pop		de
		pop		bc
		pop		af
		ret

		SECTION rodata_compiler
.sprite
		db	11000011b, 00000000b
		db	10000001b, 00111100b
		db	00000000b, 01111110b
		db	00000000b, 01100110b
		db	00000000b, 01100110b
		db	00000000b, 01111110b
		db	10000001b, 00111100b
		db	11000011b, 00000000b

		SECTION bss_compiler
.tempsp
		dw		0

