        extern  __BANK_7_head
        extern  _updateDirection
        extern  animateMenu
        extern  displayTile
        extern  keyboardScan
        extern  lookupScanCode
        extern  pressJumpMsg
        extern  printAttr
        extern  scanCodes
        extern  setAttr
        extern  setTileAttr
        extern  waitReleaseKey
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
        ; Setup the screen
        ;

        ;
        ; Copy screen 1 to screen 0
        ;
        ld      de, SCREEN_START        ; Destination address
        ld      hl, __BANK_7_head       ; Source address, bank 7 must be mapped
        ld      bc, SCREEN_LENGTH+SCREEN_ATTR_LENGTH
        ldir                            ; Copy

        ;
        ; Clear the text from the main menu
        ;
        ld      b, 0x0d                 ; Start Y position
yLoop:
        ld      c, 0x06                 ; Starting X position
xLoop:
IF  !_ZXN
        ld      a, ID_BLANK             ; ID of tile to use
        call    displayTile             ; Display the tile
ELSE
        call    clearULATile
ENDIF

        inc     c                       ; Increment the screen X position
        ld      a, c
        cp      0x06+0x13
        jr      nz, xLoop               ; and loop if not zero

        inc     b                       ; Increment the screen Y position
        ld      a, b
        cp      0x0d+0x08
        jr      nz, yLoop               ; and loop if not zero

        ;
        ; Display screen title
        ;
        ld      bc, 0x0d0a
        ld      hl, defineKeyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        bcall   printAttr

        ;
        ; Underline the title
        ;
        ld      a, ID_PLATFORM
        ld      bc, 0x0e0a              ; Starting screen Y/X location
        ld      e, 11
underline:
        call    displayTile
        call    setTileAttr             ; Requires attributes in BANK 0
        inc     c                       ; Increment the X screen location
        dec     e                       ; Decrement loop count
        jr      nz, underline           ; and loop if not zero

        screen  0                       ; Display screen 0

        ;
        ; Get key for left
        ;
        ld      bc, 0x0f0a
        ld      hl, leftMsg
        call    getInput
        ld      (scanCodes), de

        ;
        ; Get key for right
        ;
        ld      bc, 0x110a
        call    getInput
        ld      (scanCodes+3), de

        ;
        ; Get key for jump
        ;
        ld      bc, 0x130a
        call    getInput
        ld      (scanCodes+6), de

        ;
        ; Display the continue message
        ;
        ld      bc, 0x1505
        ld      hl, pressJumpMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT|FLASH
        bcall   printAttr

waitJump:
        ld      hl, lanternList
        call    animateMenu

        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      z, waitJump

waitJumpRelease:
        ld      hl, lanternList
        call    animateMenu

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
        ld      hl, lanternList
        call    animateMenu

        call    keyboardScan            ; Read the keyboard
        jr      z, getKey               ; Process key press
        ld      (key), a

        ld      hl, lanternList
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

IF  !_ZXN
        section BSS_5
ELSE
        section BSS_2
ENDIF
key:
        ds      2

IF  !_ZXN
        section RODATA_5
ELSE
        section RODATA_2
ENDIF
        ;
        ; List of lanterns on the this menu
        ;
lanternList:
        db      (lanternListEnd-lanternList)/SIZEOF_ptr
IF  !_ZXN
        dw      SCREEN_ATTR_START+(7*32)+12
        dw      SCREEN_ATTR_START+(7*32)+19
ELSE
        dw      TILEMAP_START+(7*ZXN_TILEMAP_WIDTH)+12
        dw      TILEMAP_START+(7*ZXN_TILEMAP_WIDTH)+19
ENDIF
lanternListEnd:

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
