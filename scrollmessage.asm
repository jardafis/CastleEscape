		extern	_screenTab
        public  _scroll
        section code_user

        defc	FONT	= 0x3d00
		defc	X		= 0x07
		defc	Y		= 0x00
		defc	WIDTH	= 0x10

_scroll:
		push	af
		push	bc
		push	de
		push	hl

		; Check if we are in the middle of rotating a character
		ld		a,(rotate)
		dec		a
		and		0x07
		ld		(rotate),a
		jr		nz,nextBit

		; We are not in the middle of rotating a character
		; so we need to get the next character from the message
.getChar
		ld		hl,message				; Get the address of the message
		ld		de,(messageIndex)		; Get the index into the message
		add		hl,de					; hl now points to the character we need
		ld		a,(hl)					; Read the character
		and		a						; Check if the end of the message has been reached
		jr		z,resetIndex			; Not end of message

		sub		0x20					; Font starts at ASCII 32
		inc		de						; Increment the message index
		ld		(messageIndex),de

		ld		de,FONT
		ld		l,a
		ld		h,0
		add		hl,hl					; x2
		add		hl,hl					; x4
		add		hl,hl					; x8
		add		hl,de
		ld		de,buffer
		ld		bc,8					; 8 bytes per char
		ldir							; Copy font data to our buffer

.nextBit

		; Calculate the screen start address
		ld		de,_screenTab
		ld		hl,Y					; Get Y offset
		add		hl,hl					; x 2
		add		hl,de					; Index into the screen table
		ld		e,(hl)
		inc		hl
		ld		d,(hl)
		ex		de,hl


		ld		de,buffer
		ld		b,8
.loop2
		push	bc						; Store the loop counter
		push	hl						; Store the screen address

		ld		a,X+WIDTH				; Start on the right hand side
		add		l
		ld		l,a

		and		a						; Clear the carry flag
		ld		a,(de)					; Get buffer data
		rla								; Rotate it left
		ld		(de),a					; Store buffer data
										; The carry flag contains the data we need


		ld		b,WIDTH
.loop
		ld		a,(hl)					; Get the screen data
		rla								; Rotate left taking data from the carry flag
		ld		(hl),a					; Store data back to the screen
		dec		hl						; Previous screen location
		djnz	loop					; Loop for the width of the message

		inc		de						; Next buffer address
		pop		hl						; Restore screen address
		inc		h						; Increment to next row
		pop		bc						; Restore the loop counter
		djnz	loop2					; Loop for height of characters

		pop		hl
		pop		de
		pop		bc
		pop		af
		ret

.resetIndex
		ld		d,a						; End of message detected so reset the index
		ld		e,a
		ld		(messageIndex),de
		jr		getChar					; Loop to get a character

		section rodata_user
.message
		db		"This is a test message. It Requires a font so we are using the one "
		db		"from the ZX Spectrum ROM.... ", 0x00

		section bss_user
.buffer
		ds		8
.messageIndex
		dw		0
		section	data_user
.rotate
		db		1
