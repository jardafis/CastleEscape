        extern  assert

        public  _updateDirection
        public  _waitKey
        public  keyboardScan
        public  kjScan
        public  lookupScanCode
        public  scanCodes
        public  waitKey

        section CODE_2

        include "defs.inc"

        ;
        ; Scan the keyboard for input.
        ;
        ;	Entry:
        ;		None
        ;
        ;	Exit:
        ;		a - ASCII code for key pressed or 0 if no keys are pressed
        ;		Z - Zero flag set if no key pressed
        ;
        ; Taken from http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
        ; with optimizations by IrataHack.
        ;
keyboardScan:
        push    BC
        push    HL

        ld      HL, keyMap              ; Point HL at the keyboard map
        ld      C, 8                    ; This is the number of ports (rows) to check
nextRow:
        ld      A, (HL)                 ; Get the keyboard port high byte address from table
        inc     HL                      ; Increment to list of keys
        in      A, (0xFE)               ; Read the row of keys

        ld      b, 5                    ; This is the number of keys in the row, bits 4-0
nextKey:
        rrca                            ; Shift A right; bit 0 into carry flag
        jr      NC, foundKey            ; If carry is not set, we've found our key
        inc     HL                      ; Go to next table address
        djnz    nextKey                 ; Loop around until this row finished

        dec     C                       ; Decrement row loop counter
        jr      NZ, nextRow             ; Loop around until we are done

foundKey:
        ld      A, (HL)                 ; Load the key value from the table

        or      a                       ; Update zero flag
        pop     HL
        pop     BC
        ret

        ;
        ; Inputs: None
        ; Outputs:
        ;		e	-	Direction bits
        ;
_updateDirection:
        ld      hl, scanCodes           ; Point to the scan codes
        ld      e, 0                    ; Clear our return value
nextScanCode:
        ld      a, (hl)                 ; Get IO port upper bits
        or      a                       ; Check for zero
        jr      z, kjScan               ; Z if no more scancodes
        inc     hl                      ; Point to key mask
        in      a, (0xfe)               ; Read port
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
        ; C Wrapper.
        ; Wait for a key to be pressed and released
        ;
        ;	Entry:
        ;		None
        ;
        ;	Exit:
        ;		l - ASCII code for key pressed or 0 if no keys are pressed
        ;
_waitKey:
        push    af
        call    waitKey
        ld      l, a
        pop     af
        ret

        ;
        ; Wait for a key to be pressed.
        ;
        ;	Exit:
        ;		a - ASCII code for the key pressed
        ;
waitKey:
        call    keyboardScan
        jr      z, waitKey
        ex      af, af'                 ; Save the value of the key pressed

waitKeyRelease:
        call    keyboardScan
        jr      nz, waitKeyRelease

        ex      af, af'                 ; Restore the value of the key pressed
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

        section DATA_2

        ; Port upper 8 bits, key mask, direction bit
scanCodes:
        db      0xdf, 0x02, LEFT        ; O
        db      0xdf, 0x01, RIGHT       ; P
        db      0x7f, 0x01, JUMP        ; SPACE
        db      0x00
;        db      0xfb, 0x01, UP         ; Q
;        db      0xfd, 0x01, DOWN       ; A

        section RODATA_2

keyMap:                                 ;Bit 0,  1,  2,  3,  4
        db      0xFE, 0x00, "Z", "X", "C", "V"
        db      0xFD, "A", "S", "D", "F", "G"
        db      0xFB, "Q", "W", "E", "R", "T"
        db      0xF7, "1", "2", "3", "4", "5"
        db      0xEF, "0", "9", "8", "7", "6"
        db      0xDF, "P", "O", "I", "U", "Y"
        db      0xBF, 0x0d, "L", "K", "J", "H"
        db      0x7F, " ", 0x00, "M", "N", "B"
        db      0x00                    ; No key pressed
