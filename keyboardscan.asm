        ;
        ; Taken from http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard
        ;
        section code_user

        public  _keyboardScan
        public  _updateDirection
		include "defs.asm"

_keyboardScan:
        push    AF
        push    BC
        push    DE
        push    HL                      ; Preserve H, L will be our return value
        ld      HL,Keyboard_Map         ; Point HL at the keyboard list
        ld      D,8                     ; This is the number of ports (rows) to check
        ld      C,0xFE                  ; C is always FEh for reading keyboard ports

.Read_Keyboard_0
        ld      B,(HL)                  ; Get the keyboard port address from table
        inc     HL                      ; Increment to list of keys
        in      A,(C)                   ; Read the row of keys in
        and     0x1F                    ; We are only interested in the first five bits
        ld      E,5                     ; This is the number of keys in the row

.Read_Keyboard_1
        srl     A                       ; Shift A right; bit 0 sets carry bit
        jr      NC,Read_Keyboard_2      ; If the bit is 0, we've found our key
        inc     HL                      ; Go to next table address
        dec     E                       ; Decrement key loop counter
        jr      NZ,Read_Keyboard_1      ; Loop around until this row finished
        dec     D                       ; Decrement row loop counter
        jr      NZ,Read_Keyboard_0      ; Loop around until we are done
        xor     A                       ; Clear A (no key found)
        pop     HL                      ; Restore H
        ld      L,A                     ; Overwrite L
        pop     DE
        pop     BC
        pop     AF
        ret     

.Read_Keyboard_2
        ld      A,(HL)                  ; We've found a key at this point; fetch the character code!
        pop     HL                      ; Restore H
        ld      L,A                     ; Override L
        pop     DE
        pop     BC
        pop     AF
        ret     

_updateDirection:
        push    af
        push    bc
        push    de

        ld      e,0                     ; Return value
        ld      c,0xfe                  ; C is always FEh for reading keyboard ports
        ld      hl,scanCodes

.checkUp
        ld      b,(hl)                  ; Upper port address
        inc     hl
        in      a,(c)                   ; Read row
        and     (hl)                    ; key mask
        inc     hl
        jr      nz,checkDown
        set     UP,e

.checkDown
        ld      b,(hl)                  ; Upper port address
        inc     hl
        in      a,(c)                   ; Read row
        and     (hl)                    ; key mask
        inc     hl
        jr      nz,checkLeft
        set     DOWN,e

.checkLeft
        ld      b,(hl)                  ; Upper port address
        inc     hl
        in      a,(c)                   ; Read row
        and     (hl)                    ; key mask
        inc     hl
        jr      nz,checkRight
        set     LEFT,e

.checkRight
        ld      b,(hl)                  ; Upper port address
        inc     hl
        in      a,(c)                   ; Read row
        and     (hl)                    ; key mask
        inc     hl
        jr      nz,checkFire
        set     RIGHT,e

.checkFire
        ld      b,(hl)                  ; Upper port address
        inc     hl
        in      a,(c)                   ; Read row
        and     (hl)                    ; key mask
        jr      nz,checkDone
        set     FIRE,e

.checkDone
        ld      h,0
        ld      l,e
        pop     de
        pop     bc
        pop     af
        ret     

        section bss_user

        ; Upper byte is the mask used to check for key when data is read from port
        ; Lower byte is the upper bits of the port to read
.scanCodes
        dw      0x01fb                  ; Up(Q)
        dw      0x01fd                  ; Down(A)
        dw      0x02df                  ; Left(O)
        dw      0x01df                  ; Right(P)
        dw      0x017f                  ; Jump(SPACE)

        section rodata_user

.Keyboard_Map                           ;Bit 0,  1,  2,  3,  4
        db      0xFE,"#","Z","X","C","V"
        db      0xFD,"A","S","D","F","G"
        db      0xFB,"Q","W","E","R","T"
        db      0xF7,"1","2","3","4","5"
        db      0xEF,"0","9","8","7","6"
        db      0xDF,"P","O","I","U","Y"
        db      0xBF,"\n","L","K","J","H"
        db      0x7F," ","#","M","N","B"
