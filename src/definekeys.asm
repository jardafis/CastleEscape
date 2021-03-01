        extern  _cls
        extern  displayBorder
        extern  waitKey
        extern  print
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

        public  defineKeys

        section BANK_5
        include "defs.inc"

defineKeys:
        ;
        ; Setup the screen
        ;

        ;
        ; Patch the animate coins routine to access
        ; memory @ 0x4000
        ;
        ld      hl, 0x0000              ; nop/nop
        ld      (bank7Screen), hl


        ld      de, SCREEN_START        ; Destination address
        ld      hl, 0xc000              ; Source address
        ld      bc, SCREEN_LENGTH+SCREEN_ATTR_LENGTH
        ldir                            ; Copy

        ;
        ; Clear the text in the bricks
        ;
        ;       b - Y location
        ;       c - X location
        ;       a  - Tile ID of item
        ld      a, 0x0b
        ld      bc, 0x0c06
        call    displayTile
        inc     c
        call    displayTile
        ld      c, 0x0a
        call    displayTile
        inc     c
        call    displayTile
        inc     c
        call    displayTile
        ld      c, 0x10
        call    displayTile
        inc     c
        call    displayTile

        ld      d, 0x0d                 ; Start Y position to clear
        ld      c, 8                    ; Number of rows to clear
yLoop:

        ld      e, 0x06                 ; Starting X position to clear
        ld      b, 0x13                 ; Number of columns to clear
xLoop:
        push    bc

        ld      bc, de
        call    displayTile
        inc     e

        pop     bc
        djnz    xLoop

        inc     d
        dec     c
        jr      nz, yLoop

        ld      bc, 0x0d0a
        ld      hl, defineKeyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        call    printAttr

        screen  0                       ; Now it's setup switch to screen 0

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
        ld      hl, rightMsg
        call    getInput
        ld      (scanCodes+3), de

        ;
        ; Get key for jump
        ;
        ld      bc, 0x130a
        ld      hl, jumpMsg
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
