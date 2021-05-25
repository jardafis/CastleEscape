        extern  printAttr
        extern  LOAD_SONG
        extern  PLAYER_OFF
        extern  _updateDirection
        extern  rotateCount
        extern  currentCoinTable
        extern  animateMenu

        public  titleScreen
        public  pressJumpMsg

        section BANK_5
        include "defs.inc"

titleScreen:
        ;
        ; Start the title song
        ;
        LD      A, TITLE_MUSIC
        CALL    LOAD_SONG

        ;
        ; Display the continue message
        ;
        ld      bc, 0x1505
        ld      hl, pressJumpMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT|FLASH
        call    printAttr

        ;
        ; Setup the coin table for the main menu
        ;
        ld      hl, coinTable
        ld      (currentCoinTable), hl

        ;
        ; Reset counter used for coin rotation
        ;
        xor     a
        ld      (rotateCount), a
waitJump:
        ld      hl, lanternList
        call    animateMenu
        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      z, waitJump

waitNoJump:
        ld      hl, lanternList
        call    animateMenu

        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      nz, waitNoJump

        call    PLAYER_OFF

        ret

;        section rodata_user
pressJumpMsg:
        db      "Press Jump to Continue", 0x00

        ;
        ; List of lanterns on the title screen
        ;
lanternList:
        db      4
        dw      SCREEN_ATTR_START+(12*32)+9
        dw      SCREEN_ATTR_START+(12*32)+10
        dw      SCREEN_ATTR_START+(12*32)+22
        dw      SCREEN_ATTR_START+(12*32)+23

        ;
        ; List of coins on the title screen
        ; Specified by x/y pixel addresses
        ;
coinTable:
        db      0x01, 0x16*8, 0x0f*8, 0x00
        db      0x01, 0x17*8, 0x0f*8, 0x01
        db      0x01, 0x18*8, 0x11*8, 0x02
        db      0xff
