        extern  printAttr
        extern  pressJumpMsg
        extern  _updateDirection
        extern  lookupScanCode
        extern  scanCodes
        extern  setAttr
        extern  displayTile
        extern  _lanternFlicker
        extern  rotateCount
        extern  _animateCoins
        extern  keyboardScan
        extern  bank7Screen
        extern  animateMenu
        extern  waitReleaseKey
        extern  setTileAttr
        extern  __BANK_7_head

        public  defineKeys

        section BANK_5
        include "defs.inc"

defineKeys:
        push    af
        ;
        ; Setup the screen
        ;

        ;
        ; Patch the animate coins routine to access
        ; memory @ 0x4000 (screen 0)
        ;
        ld      hl, NOP_OPCODE<<8|NOP_OPCODE
        ld      (bank7Screen), hl

        ;
        ; Copy screen 1 to screen 0
        ;
        ld      de, SCREEN_START        ; Destination address
        ld      hl, __BANK_7_head       ; Source address, bank 7 must be mapped
        ld      bc, SCREEN_LENGTH+SCREEN_ATTR_LENGTH
        ldir                            ; Copy

        BANK    0                       ; Bank 0 contains the tile attributes

        ;
        ; Clear the text from the main menu
        ;
        ld      a, ID_BLANK             ; ID of tile to use
        ld      b, 0x0d                 ; Start Y position
        ld      e, 8                    ; Number of rows
yLoop:
        ld      c, 0x06                 ; Starting X position
        ld      d, 0x13                 ; Number of columns
xLoop:
        call    displayTile             ; Display the tile
        inc     c                       ; Increment the screen X position
        dec     d                       ; Decrement column counter
        jr      nz, xLoop               ; and loop if not zero

        inc     b                       ; Increment the screen Y position
        dec     e                       ; Decrement row counter
        jr      nz, yLoop               ; and loop if not zero

        ;
        ; Display screen title
        ;
        ld      bc, 0x0d0a
        ld      hl, defineKeyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        call    printAttr

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
        call    printAttr

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
        call    printAttr
        push    hl

        ld      a, PAPER_BLACK|INK_GREEN|BRIGHT|FLASH
        call    setAttr

        push    bc
getKey:
        ld      hl, lanternList
        call    animateMenu

        call    keyboardScan            ; Read the keyboard
        or      a                       ; If a key has been pressed
        jr      z, getKey               ; jump to process it.
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
        ld      hl, key

printKey:
        ld      a, PAPER_BLACK|INK_GREEN|BRIGHT
        call    printAttr

        ld      a, (key)
        call    lookupScanCode
        pop     hl
        ret

        section bss_user
key:
        ds      2

        section rodata_user
        ;
        ; List of lanterns on the this menu
        ;
lanternList:
        db      4
        dw      SCREEN_ATTR_START+(7*32)+12
        dw      SCREEN_ATTR_START+(7*32)+13
        dw      SCREEN_ATTR_START+(7*32)+18
        dw      SCREEN_ATTR_START+(7*32)+19

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
