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

        public  defineKeys

        section BANK_5
        include "defs.inc"

defineKeys:
        ;
        ; Setup the screen
        ;
        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls

        call    displayBorder

        ld      bc, 0x040a
        ld      hl, defineKeyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        call    printAttr

        screen  0                       ; Now it's setup switch to screen 0

        ;
        ; Get key for left
        ;
        ld      bc, 0x070a
        ld      hl, leftMsg
        call    getInput
        ld      (scanCodes), de

        ;
        ; Get key for right
        ;
        ld      bc, 0x090a
        ld      hl, rightMsg
        call    getInput
        ld      (scanCodes+3), de

        ;
        ; Get key for jump
        ;
        ld      bc, 0x0b0a
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
        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      z, waitJump

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
        call    print
        ld      a, PAPER_BLACK|INK_GREEN|BRIGHT|FLASH
        call    setAttr

        call    waitKey
        ld      (key), a

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
        db      " ", 0x00

        section rodata_user
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
