;
; Taken from http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
;
	SECTION	code_compiler

	PUBLIC	_keyboardScan
	PUBLIC	_updateDirection

_keyboardScan:
										PUSH AF
										PUSH BC
										PUSH DE
										PUSH HL									; Preserve H, L will be our return value
										LD HL,Keyboard_Map              		; Point HL at the keyboard list
                                        LD D,8                                  ; This is the number of ports (rows) to check
                                        LD C,0xFE                            	; C is always FEh for reading keyboard ports
.Read_Keyboard_0
								        LD B,(HL)                               ; Get the keyboard port address from table
                                        INC HL                                  ; Increment to list of keys
                                        IN A,(C)                                ; Read the row of keys in
                                        AND 0x1F                                ; We are only interested in the first five bits
                                        LD E,5                                  ; This is the number of keys in the row
.Read_Keyboard_1
								        SRL A                                   ; Shift A right; bit 0 sets carry bit
                                        JR NC,Read_Keyboard_2   				; If the bit is 0, we've found our key
                                        INC HL                                  ; Go to next table address
                                        DEC E                                   ; Decrement key loop counter
                                        JR NZ,Read_Keyboard_1   				; Loop around until this row finished
                                        DEC D                                   ; Decrement row loop counter
                                        JR NZ,Read_Keyboard_0   				; Loop around until we are done
                                        AND A									; Clear A (no key found)
										POP HL									; Restore H
                                        LD	L,A									; Overwrite L
                                        POP DE
                                        POP BC
                                        POP AF
                                        RET
.Read_Keyboard_2
										LD A,(HL)                               ; We've found a key at this point; fetch the character code!
										POP HL									; Restore H
                                        LD	L,A									; Override L
                                        POP DE
                                        POP BC
                                        POP AF
                                        RET

		; Bit numbers for directions
		defc	FIRE  = 4
		defc	UP	  = 3
		defc	DOWN  = 2
		defc	LEFT  = 1
		defc	RIGHT = 0

_updateDirection:
		push	af
		push	bc
		push	de

		ld		e,0			; Return value
		ld		c,0xfe		; C is always FEh for reading keyboard ports
		ld		hl,scanCodes

.checkUp
		ld		b,(hl)		; Upper port address
		inc		hl
		in		a,(c)       ; Read row
		and		(hl)		; key mask
		inc		hl
		jr		nz,checkDown
		set		UP,e
.checkDown
		ld		b,(hl)		; Upper port address
		inc		hl
		in		a,(c)       ; Read row
		and		(hl)		; key mask
		inc		hl
		jr		nz,checkLeft
		set		DOWN,e
.checkLeft
		ld		b,(hl)		; Upper port address
		inc		hl
		in		a,(c)       ; Read row
		and		(hl)		; key mask
		inc		hl
		jr		nz,checkRight
		set		LEFT,e
.checkRight
		ld		b,(hl)		; Upper port address
		inc		hl
		in		a,(c)       ; Read row
		and		(hl)		; key mask
		inc		hl
		jr		nz,checkFire
		set		RIGHT,e
.checkFire
		ld		b,(hl)		; Upper port address
		inc		hl
		in		a,(c)       ; Read row
		and		(hl)		; key mask
		jr		nz,checkDone
		set		FIRE,e
.checkDone
		ld		h,0
		ld		l,e
		pop		de
		pop		bc
		pop		af
		ret

		SECTION bss_compiler
		; Upper byte is the mask used to check for key when data is read from port
		; Lower byte is the upper bits of the port to read
.scanCodes
		dw	0x01fb	; Up(Q)
		dw	0x01fd	; Down(A)
		dw	0x02df	; Left(O)
		dw	0x01df	; Right(P)
		dw	0x017f	; Jump(SPACE)

		SECTION rodata_compiler

.Keyboard_Map ;Bit 0,  1,  2,  3,  4
		DB	0xFE,"#","Z","X","C","V"
		DB	0xFD,"A","S","D","F","G"
		DB	0xFB,"Q","W","E","R","T"
		DB	0xF7,"1","2","3","4","5"
		DB	0xEF,"0","9","8","7","6"
		DB	0xDF,"P","O","I","U","Y"
		DB	0xBF,"\n","L","K","J","H"
		DB	0x7F," ","#","M","N","B"
