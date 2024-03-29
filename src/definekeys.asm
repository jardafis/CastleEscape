        extern  _updateDirection
        extern  displayTile
        extern  keyboardScan
        extern  lookupScanCode
        extern  pressJumpMsg
        extern  printAttr
        extern  scanCodes
        extern  setAttr
        extern  setTileAttr
        extern  waitReleaseKey
        extern  flickerMenu
IF  _ZXN
        extern  clearULATile
ENDIF

        public  defineKeys

IF  !_ZXN
        section CODE_5
ELSE
        section CODE_2
ENDIF
        #include    "defs.inc"

defineKeys:
        push    af
        ;
        ; Clear the text from the main menu
        ;
        ld      b, 0x11                 ; Start Y position
yLoop:
        ld      c, 0x08                 ; Starting X position
xLoop:
IF  !_ZXN
        ld      a, ID_BLANK             ; ID of tile to use
        call    displayTile             ; Display the tile
ELSE
        call    clearULATile
ENDIF

        inc     c                       ; Increment the screen X position
        ld      a, c
        cp      0x08+0x12
        jr      nz, xLoop               ; and loop if not zero

        inc     b                       ; Increment the screen Y position
        ld      a, b
        cp      0x11+0x06
        jr      nz, yLoop               ; and loop if not zero

        ;
        ; Display screen title
        ;
        ld      bc, 0x0f0a
        ld      hl, defineKeyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        bcall   printAttr

        ;
        ; Underline the title
        ;
        ld      a, ID_PLATFORM
        ld      bc, 0x100a              ; Starting screen Y/X location
        ld      e, 11
underline:
        call    displayTile
        call    setTileAttr             ; Requires attributes in BANK 0
        inc     c                       ; Increment the X screen location
        dec     e                       ; Decrement loop count
        jr      nz, underline           ; and loop if not zero

        ;
        ; Get key for left
        ;
        ld      bc, 0x110a
        ld      hl, leftMsg
        call    getInput
        ld      (scanCodes), de

        ;
        ; Get key for right
        ;
        ld      bc, 0x130a
        call    getInput
        ld      (scanCodes+3), de

        ;
        ; Get key for jump
        ;
        ld      bc, 0x150a
        call    getInput
        ld      (scanCodes+6), de

        ;
        ; Display the continue message
        ;
        ld      bc, 0x1705
        ld      hl, pressJumpMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT|FLASH
        bcall   printAttr

waitJump:
        halt
        call    flickerMenu

        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      z, waitJump

waitJumpRelease:
        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      nz, waitJumpRelease

        pop     af
        ret

        ;
        ; Display a prompt asking to input a direction key.
        ; When the key is pressed display it. If SPACE or ENTER
        ; is pressed, display the approprate message.
        ;
        ;   Input:
        ;       bc - Y/X screen position of prompt
        ;       hl - Pointer to message to display
        ;
        ;   Output:
        ;       de - Scan code for the key pressed
getInput:
        ld      a, PAPER_BLACK|INK_WHITE
        bcall   printAttr
        push    hl

        ld      a, PAPER_BLACK|INK_GREEN|BRIGHT|FLASH
        call    setAttr

        push    bc
getKey:
        halt
        call    flickerMenu

        call    keyboardScan            ; Read the keyboard
        jr      z, getKey               ; Process key press
        ld      (key), a

        call    waitReleaseKey

        pop     bc

        cp      0x20
        jr      nz, notSpace
        ld      hl, spaceMsg
        jr      printKey
notSpace:
        cp      0x0d
        jr      nz, notEnter
        ld      hl, enterMsg
        jr      printKey
notEnter:
        cp      SYM
        jr      nz, notSYM
        ld      hl, symMsg
        jr      printKey
notSYM:
        cp      SHIFT
        jr      nz, notShift
        ld      hl, shiftMsg
        jr      printKey
notShift:
        ld      hl, key

printKey:
        ld      a, PAPER_BLACK|INK_GREEN|BRIGHT
        bcall   printAttr

        ld      a, (key)
        call    lookupScanCode
        pop     hl
        ret

        section BSS_2
key:
        ds      2

        section RODATA_4
defineKeyMsg:
        db      "Define Keys", 0x00
leftMsg:
        db      "Left    - ", 0x00
rightMsg:
        db      "Right   - ", 0x00
jumpMsg:
        db      "Jump    - ", 0x00
spaceMsg:
        db      "SPACE", 0x00
enterMsg:
        db      "ENTER", 0x00
shiftMsg:
        db      "SHIFT", 0x00
symMsg:
        db      "SYM", 0x00
