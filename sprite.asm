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
		ld		l,(ix+1)	; get the y position
		add		hl,hl		; multiply by 2
		ld		sp,_screenTab
		add		hl,sp
		ld		sp,hl


		ld		e,(ix+2)
		ld		d,(ix+3)


		ld		c,(ix+0)	; Get the X offset
		srl		c			; divide by 8 to get byte address
		srl		c
		srl		c
		ld		b,8
.copyloop
		pop		hl			; get screen row adress
		ld		a,l
		add		c			; add x offset
		ld		l,a

		ld		a,(hl)
		ld		(de),a
		inc		de
		inc		hl

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
		ld		l,(ix+1)	; get the y position
		add		hl,hl		; multiply by 2
		ld		sp,_screenTab
		add		hl,sp
		ld		sp,hl

		; Get buffer address
		ld		e,(ix+2)
		ld		d,(ix+3)

		ld		b,8
		ld		c,(ix+0)	; Get the X offset
		srl		c			; divide by 8 to get byte address
		srl		c
		srl		c
.pasteloop
		pop		hl			; get screen row adress
		ld		a,l
		add		c			; add x offset
		ld		l,a

		ld		a,(de)
		ld		(hl),a
		inc		de
		inc		hl

		ld		a,(de)
		ld		(hl),a
		inc		de

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

		; Calculate the offset into the screen table
		ld		h,0
		ld		l,(ix+1)	; get the y position
		add		hl,hl		; multiply by 2
		ld		sp,_screenTab
		add		hl,sp
		ld		sp,hl

		ld		a,(ix+0)	; Get the X offset
		ld		c,a			; Store it
		and		0x07		; Get the sprite shift index
		; Multiply by 32
		add		a			; x2
		add		a			; x4
		add		a			; x8
		add		a			; x16
		add		a			; x32
		ld		h,0
		ld		l,a
		ld		de,spriteShift0
		add		hl,de
		ex		de,hl

		; c is the pixel X offset
		; Divide by 8 to get byte address
		srl		c			; /2
		srl		c			; /4
		srl		c			; /8
		ld		b,8			; Sprite height
.loop2
		pop		hl			; get screen row adress
		ld		a,l
		add		a,c			; add x offset
		ld		l,a

		ld		a,(de)		; Get mask data
		and		(hl)		; Logical AND screen data with mask
		ld		(hl),a		; Store result back to screen
		inc		de			; Next byte of sprite data
		ld		a,(de)		; Get sprite data
		or		(hl)		; Logical OR screen data with sprite data
		ld		(hl),a		; Store result back to the screen
		inc		de			; Next byte of sprite data

		inc		hl			; Next screen X address

		ld		a,(de)		; Get mask data
		and		(hl)		; Logical AND screen data with mask
		ld		(hl),a		; Store result back to screen
		inc		de			; Next byte of sprite data
		ld		a,(de)		; Get sprite data
		or		(hl)		; Logical OR screen data with sprite data
		ld		(hl),a		; Store result back to the screen
		inc		de			; Next byte of sprite data

		djnz	loop2

		ld		sp,(tempsp)
		ei

		pop		ix
		pop		hl
		pop		de
		pop		bc
		pop		af
		ret

		SECTION rodata_compiler
		; 	  mask,      data,     mask,     data
.spriteShift0
		db	11000011b, 00000000b,11111111b,00000000b
		db	10000001b, 00111100b,11111111b,00000000b
		db	00000000b, 01111110b,11111111b,00000000b
		db	00000000b, 01100110b,11111111b,00000000b
		db	00000000b, 01100110b,11111111b,00000000b
		db	00000000b, 01111110b,11111111b,00000000b
		db	10000001b, 00111100b,11111111b,00000000b
		db	11000011b, 00000000b,11111111b,00000000b
.spriteShift1
		db	11100001b,00000000b,11111111b,00000000b
		db	11000000b,00011110b,11111111b,00000000b
		db	10000000b,00111111b,01111111b,00000000b
		db	10000000b,00110011b,01111111b,00000000b
		db	10000000b,00110011b,01111111b,00000000b
		db	10000000b,00111111b,01111111b,00000000b
		db	11000000b,00011110b,11111111b,00000000b
		db	11100001b,00000000b,11111111b,00000000b
.spriteShift2
		db	11110000b,00000000b,11111111b,00000000b
		db	11100000b,00001111b,01111111b,00000000b
		db	11000000b,00011111b,00111111b,10000000b
		db	11000000b,00011001b,00111111b,10000000b
		db	11000000b,00011001b,00111111b,10000000b
		db	11000000b,00011111b,00111111b,10000000b
		db	11100000b,00001111b,01111111b,00000000b
		db	11110000b,00000000b,11111111b,00000000b
.spriteShift3
		db	11111000b,00000000b,01111111b,00000000b
		db	11110000b,00000111b,00111111b,10000000b
		db	11100000b,00001111b,00011111b,11000000b
		db	11100000b,00001100b,00011111b,11000000b
		db	11100000b,00001100b,00011111b,11000000b
		db	11100000b,00001111b,00011111b,11000000b
		db	11110000b,00000111b,00111111b,10000000b
		db	11111000b,00000000b,01111111b,00000000b
.spriteShift4
		db	11111100b,00000000b,00111111b,00000000b
		db	11111000b,00000011b,00011111b,11000000b
		db	11110000b,00000111b,00001111b,11100000b
		db	11110000b,00000110b,00001111b,01100000b
		db	11110000b,00000110b,00001111b,01100000b
		db	11110000b,00000111b,00001111b,11100000b
		db	11111000b,00000011b,00011111b,11000000b
		db	11111100b,00000000b,00111111b,00000000b
.spriteShift5
		db	11111110b,00000000b,00011111b,00000000b
		db	11111100b,00000001b,00001111b,11100000b
		db	11111000b,00000011b,00000111b,11110000b
		db	11111000b,00000011b,00000111b,00110000b
		db	11111000b,00000011b,00000111b,00110000b
		db	11111000b,00000011b,00000111b,11110000b
		db	11111100b,00000001b,00001111b,11100000b
		db	11111110b,00000000b,00011111b,00000000b
.spriteShift6
		db	11111111b,00000000b,00001111b,00000000b
		db	11111110b,00000000b,00000111b,11110000b
		db	11111100b,00000001b,00000011b,11111000b
		db	11111100b,00000001b,00000011b,10011000b
		db	11111100b,00000001b,00000011b,10011000b
		db	11111100b,00000001b,00000011b,11111000b
		db	11111110b,00000000b,00000111b,11110000b
		db	11111111b,00000000b,00001111b,00000000b
.spriteShift7
		db	11111111b,00000000b,10000111b,00000000b
		db	11111111b,00000000b,00000011b,01111000b
		db	11111110b,00000000b,00000001b,11111100b
		db	11111110b,00000000b,00000001b,11001100b
		db	11111110b,00000000b,00000001b,11001100b
		db	11111110b,00000000b,00000001b,11111100b
		db	11111111b,00000000b,00000011b,01111000b
		db	11111111b,00000000b,10000111b,00000000b

		SECTION bss_compiler
.tempsp
		dw		0

