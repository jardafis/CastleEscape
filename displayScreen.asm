	EXTERN _screenTab
	EXTERN _tile0

	SECTION code_compiler
	PUBLIC _displayScreen

	defc	xPos		= 0x0000
	defc	yPos		= 0x0001

	;
	; Display a complete tile map
	;
	; On entry hl points to the tilemap to be displayed.
	; Tilemaps are converted to binary using the TiledToBinary app.
	;
_displayScreen:
	; Save the registers we are going to use so we can return to C
	push	af
	push 	bc
	push	de
	push	hl
	push	ix

	; Get the address of the tilemap
	; passed on the stack
	ld		ix,12	; the 5 pushes above plus return address
	add		ix,sp
	ld		l,(ix+0)
	ld		h,(ix+1)

	; IX points to the temporary storage for our variables
	ld		ix,varbase

	; HL points to the tilemap
	; Offset 0x11 is where the tilemap actually starts
	ld		de,0x11
	add		hl,de

	; Zero out the Y character location
	; We use 16 bits because we need to multiple by 16
	; to get the screenTab offset and the screen is 192
	; lines.
	ld		de,0
	ld		(y),de

	; 24 Character rows
	ld		b,24
.yloop
	push	bc

	; Zero out the X character location
	xor		a
	ld		(x), a

	; 32 character columns
	ld		b,32
.xloop
	ld		a,(hl)		; read the tile index
	and		a
	jr		z,nextTile	; if the index is 0 skip tile

	push	bc			; save the loop counter
	push	hl			; save thte tilemap pointer
	push	af			; save tile index

	; Claculate the screen Y address
	ld		hl,(y)		; get the y position	  16
	add		hl,hl		; multiply by 16          11
	add		hl,hl		;                         11
	add		hl,hl		;                         11
	add		hl,hl		;                         11
	ld		de,_screenTab	;                     10
	add		hl,de		;                         11

	; Load the screen address into BC
	; and add the X character position
	ld		a,(x)		; Get the X offset        13
	add		a,(hl)		; low order byte          7
	ld		c,a									; 4
	inc		hl									; 6
	ld		b,(hl)		; high order byte         7
;                                           Total 118
	; Calculate the tile index address
	pop		af			; restore tile index
	dec		a			; Out tile indexes should be 0 based
	ld		l,a
	ld		h,0
	add		hl,hl		; Multuply by 8 since 8 bytes per tile
	add		hl,hl
	add		hl,hl
	ld		de,_tile0
	add		hl,de

	; Display the tile. We are going to use the
	; stack pointer to load a 16 bit value so
	; we need to disable interrupts.
	di
	; Save the current stack pointer
	ld		(tempsp),sp
	; Point the stack at the tile data
	ld		sp,hl
	; Point hl at the screen address
	ld		hl,bc

	; Pop 2 bytes of tile data and store it
	; to the screen.
	pop		bc      ; 10
	ld		(hl),c  ; 7
	inc		h		; Add 256 to screen address 4
	ld		(hl),b  ; 7
	inc		h		; Add 256 to screen address 4

	; Pop 2 bytes of tile data and store it
	; to the screen.
	pop		bc      ; 10
	ld		(hl),c  ; 7
	inc		h		; 4
	ld		(hl),b  ; 7
	inc		h		; 4

	; Pop 2 bytes of tile data and store it
	; to the screen.
	pop		bc      ; 10
	ld		(hl),c  ; 7
	inc		h		; 4
	ld		(hl),b  ; 7
	inc		h		; 4

	; Pop 2 bytes of tile data and store it
	; to the screen.
	pop		bc      ; 10
	ld		(hl),c  ; 7
	inc		h		; 4
	ld		(hl),b  ; 7

	; Restore the stack pointer.
	ld		sp,(tempsp)
	ei

	pop		hl		; tile map pointer
	pop		bc		; loop counter
.nextTile
	inc		hl		; next tile
	inc		hl

	; next x location
	inc		(ix+xPos)

	djnz	xloop

	; next y location
	inc		(ix+yPos)

	pop		bc
	djnz	yloop

	pop		ix
	pop		hl
	pop		de
	pop		bc
	pop		af
	ret

	SECTION	bss_compiler
.varbase
.x
	db	0
.y
	dw	0
.tempsp
	dw	0
