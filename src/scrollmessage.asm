        extern  rand
        extern  font

        public  _scroll
        public  _scrollInit
        public  _scrollReset
        section CODE_2

        defc    xPos=0x07               ; Start column of message
        defc    Y=0x01                  ; Start character row of message
        defc    WIDTH=0x12              ; Width, in columns, of message area
        defc    MESSAGE_ATTR=PAPER_BLACK|INK_WHITE|BRIGHT
                                        ; Attribute for the message
        #include    "defs.inc"

        defc    MAX_MESSAGE=(messagesEnd-messages)/2
        ;
        ; Inputs:
        ;
_scrollInit:
        push    af
        push    bc
        push    de
        push    hl

        ;
        ; Initialize the screen address to top right corner
        ;
        ; Calculate the screen address
        ld      a, Y                    ; Y character position
        rrca                            ; Move lower 3 bits to the upper 3 bits
        rrca
        rrca
        and     %11100000               ; Bits 5-3 of pixel row
        or      xPos+WIDTH-1            ; X character position
        ld      l, a

        ld      a, Y                    ; Y character position
        and     %00011000               ; Bits 7-6 of pixel row
        or      0x40                    ; 0x40 or 0xc0
        ld      h, a

        ld      (screenAddr), hl        ; Save this screen address for use by the scroll routine

        ;
        ; Clear the message area on the screen
        ;
        xor     a                       ; Zero accumulator
        ld      c, 8                    ; Height of character
clearRow:
        ld      de, hl                  ; Store the screen address

        ld      b, WIDTH                ; Width of scrolling window
clearCol:
        ld      (hl), a                 ; Store 0 to the screen
        dec     hl                      ; Next character to the left
        djnz    clearCol                ; Loop for the width of the message

        ld      hl, de                  ; Restore screen address
        inc     h                       ; Increment to next row
        dec     c
        jr      nz, clearRow

        call    _scrollReset

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

_scrollReset:
        push    af
        push    bc
        push    de
        push    hl

        call    rand
        ld      a, l
        and     %00000111

        mod     MAX_MESSAGE

        ax      SIZEOF_ptr
        ld      hl, messages
        addhl   a

        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        ;
        ; Reset the message pointer
        ;
        ld      (messageStart), bc
        ld      (messagePointer), bc

        ;
        ; Initialize the rotate counter
        ; It will be updated by the scroll routine
        ;
        ld      a, 0x80
        ld      (rotate), a

        ;
        ; Set the screen attributes for the message
        ;
        ld      de, SCREEN_ATTR_START   ; Get the start of the screen attributes
        ld      hl, Y                   ; Get the Y position and multiply by 32
        hlx     32
        add     hl, de                  ; Add it to the attr start address
        ld      a, xPos
        add     l
        ld      l, a
        ld      de, hl
        inc     de

        ld      (hl), MESSAGE_ATTR
        ld      bc, WIDTH-1
        ldir

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

_scroll:
        ; Check if we need to get the next character of the message
        ld      hl, rotate
        rlc     (hl)
        jp      c, getNextChar

shift:
        ld      hl, (screenAddr)        ; Screen address of right hand side of message calculated by scrollInit
        ld      de, charBuffer

        ld      c, l                    ; save l which is the screen X starting offset
        ld      b, 8                    ; Height of character
rowLoop:
        ld      a, (de)                 ; Get buffer data
        rla                             ; Rotate it left through the carry flag
        ld      (de), a                 ; Store buffer data
        inc     de                      ; Next buffer address
        ; The carry flag contains the data we will shift
        ; into the next character on the screen

colLoop:
        REPT    WIDTH
        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left
        ENDR

        ld      l, c                    ; Restore low order byte of screen address
        inc     h                       ; +0x100 To increment to next row
        djnz    rowLoop

        ret

getNextChar:
        ; Page-in the font bank
        ld      a, font>>16
        ld      bc, IO_BANK
        out     (c), a

        ; Need to get the next character from the message
        ld      hl, (messagePointer)    ; Get the message pointer
        ld      a, (hl)                 ; Read the character
        and     a                       ; Check if the end of the message has been reached
        jp      z, resetMessagePointer  ; Reset pointer if we reach the end of the message
        cp      0xff
        jp      z, doPadding
        inc     hl                      ; Otherwise increment the message pointer
        ld      (messagePointer), hl    ; and save it

        sub     0x20                    ; Font starts at ASCII 32

        ;
        ; Copy 8 bytes of font data corresponding to the
        ; character from the ROM font to our character buffer.
        ; This allows us to rotate and save the character
        ; without corrupting the actual font.
        ;
        ld      l, a                    ; Get the font character index
        ld      h, 0                    ; and multiply it by 8
        hlx     8
        ld      de, font                ; Pointer to the font
        add     hl, de                  ; hl points to the font data address
        ld      de, charBuffer          ; Point to our character buffer address

        REPT    8
        ldi
        ENDR

        ; Page-in bank 0
        ld      bc, IO_BANK
        out     (c), 0

        jp      shift

doPadding:
        ld      hl, padding
        ld      (messagePointer), hl
        jp      getNextChar             ; Loop to get a character

resetMessagePointer:
        ld      hl, (messageStart)
        ld      (messagePointer), hl
        jp      getNextChar             ; Loop to get a character

        section RODATA_2
messages:
        dw      message0, message1, message2, message3, message4, message5, message6
messagesEnd:

        section RODATA_4
message0:
        db      "Escape the castle...", 0xff
message1:
        db      "Hurry...", 0xff
message2:
        db      "Collect the coins for points...", 0xff
message3:
        db      "Purple eggs give you wiiings...", 0xff
message4:
        db      "Prolong your life with hearts XOXO...", 0xff
message5:
        db      "Don't fall too far!", 0xff
message6:
        db      "I am constant as the northern star...", 0xff
padding:
        ds      0x10, 0x20
        db      0x00

        section BSS_2
messagePointer:
        ds      2                       ; Pointer to the current location in the message
messageStart:
        ds      2                       ; Pointer to the start of the message
screenAddr:
        ds      2                       ; Pointer to the top right-hand location on the screen
charBuffer:
        ds      8                       ; Buffer to store font data while we are rotating it
rotate:
        ds      1                       ; Counter so we know when to get the next character from the message
