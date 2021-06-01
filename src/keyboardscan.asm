        extern  assert

        public  _keyboardScan
        public  keyboardScan
        public  _updateDirection
        public  kjScan
        public  waitKey
        public  lookupScanCode
        public  scanCodes

        section code_user

        include "defs.inc"

		;
		; C Wrapper.
		; Scan the keyboard for input.
		;
		;	Entry:
		;		None
		;
		;	Exit:
		;		l - ASCII code for key pressed or 0 if no keys are pressed
		;
_keyboardScan:
        push    af
        call    keyboardScan
        ld      l, a
        pop     af
        ret

		;
		; Scan the keyboard for input.
		;
		;	Entry:
		;		None
		;
		;	Exit:
		;		a - ASCII code for key pressed or 0 if no keys are pressed
        ;
        ; Taken from http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
        ;
keyboardScan:
        push    BC
        push    DE
        push    HL                      ; Preserve H, L will be our return value

        ld      HL, keyMap              ; Point HL at the keyboard list
        ld      D, 8                    ; This is the number of ports (rows) to check
        ld      C, 0xFE                 ; C is always FEh for reading keyboard ports

nextRow:
        ld      B, (HL)                 ; Get the keyboard port address from table
        inc     HL                      ; Increment to list of keys
        in      A, (C)                  ; Read the row of keys in

        ld      b, 5                    ; This is the number of keys in the row
nextKey:
        srl     A                       ; Shift A right; bit 0 sets carry bit
        jr      NC, foundKey            ; If the bit is 0, we've found our key
        inc     HL                      ; Go to next table address
        djnz    nextKey                 ; Loop around until this row finished

        dec     D                       ; Decrement row loop counter
        jr      NZ, nextRow             ; Loop around until we are done

        xor     A                       ; Clear A (no key found)
        pop     HL                      ; Restore H
        pop     DE
        pop     BC
        ret

foundKey:
        ld      A, (HL)                 ; We've found a key at this point; fetch the character code!
        pop     HL                      ; Restore HL
        pop     DE
        pop     BC
        ret

		;
		; Inputs: None
		; Outputs:
		;		e	-	Direction bits
		;
_updateDirection:
        ld      hl, scanCodes           ; Point to the scan codes
        ld      c, 0xfe                 ; Lower 8 bits of the IO port
        ld      e, 0                    ; Clear our return value
nextScanCode:
        ld      a, (hl)                 ; Get IO port upper bits
        or      a                       ; Check for zero
        jr      z, kjScan               ; Z if no more scancodes
        ld      b, a                    ; Store port upper bits in 'b'
        inc     hl                      ; Point to key mask
        in      a, (c)                  ; Read port
        and     (hl)                    ; Logicaly and mask
        inc     hl                      ; Point to Direction bit
        jr      nz, notPressed          ; If the bit was set the key is not pressed
        ld      a, e                    ; Get the return value
        or      (hl)                    ; Logically or the bit for the pressed key
        ld      e, a                    ; Save the return value
notPressed:
        inc     hl                      ; Point to next key
        jr      nextScanCode            ; Loop until we have checked all scan codes

		;
		; The 3 opcode below will be replaced with
		; jp	readKempston if a Kempston joystick
		; was detected during game initialization.
		;
kjScan:
        ret
        nop
        nop
        ret

		;
		; Wait for a key to be pressed.
		;
		;	Exit:
		;		a - ASCII code for the key pressed
		;
waitKey:
        push    bc

waitKeyPress:
        call    keyboardScan
        or      a
        jr      z, waitKeyPress

        ld      b, a                    ; Save the value of the key pressed
waitKeyRelease:
        call    keyboardScan
        or      a
        jr      nz, waitKeyRelease

        ld      a, b                    ; Restore the value of the key pressed

        pop     bc
        ret

        ;
        ; Lookup the scan code for the ASCII character passed in 'a'
        ;
        ;   Input:
        ;       a - ASCII key code
        ;
        ;   Output:
        ;       de - Scan code; e = I/O port, d = bit mask
        ;
lookupScanCode:
        push    af
        push    bc
        push    hl

        ld      hl, keyMap

        ld      c, 8
rowLoop:
        ld      e, (hl)
        inc     hl

        ld      d, 1
        ld      b, 5
keyLoop:
        cp      (hl)
        jr      z, foundScanCode
        inc     hl
        sla     d
        djnz    keyLoop

        dec     c
        jr      nz, rowLoop
        assert

foundScanCode:
        pop     hl
        pop     bc
        pop     af
        ret

        section data_user

        ; Port upper 8 bits, key mask, direction bit
scanCodes:
        db      0xdf, 0x02, LEFT        ; O
        db      0xdf, 0x01, RIGHT       ; P
        db      0x7f, 0x01, JUMP        ; SPACE
        db      0x00
;        db      0xfb, 0x01, UP         ; Q
;        db      0xfd, 0x01, DOWN       ; A

        section rodata_user

keyMap:                                 ;Bit 0,  1,  2,  3,  4
        db      0xFE, 0x00, "Z", "X", "C", "V"
        db      0xFD, "A", "S", "D", "F", "G"
        db      0xFB, "Q", "W", "E", "R", "T"
        db      0xF7, "1", "2", "3", "4", "5"
        db      0xEF, "0", "9", "8", "7", "6"
        db      0xDF, "P", "O", "I", "U", "Y"
        db      0xBF, 0x0d, "L", "K", "J", "H"
        db      0x7F, " ", 0x00, "M", "N", "B"
