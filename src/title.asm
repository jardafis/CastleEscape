        extern  _updateDirection
        extern  animateMenu
        extern  currentCoinTable
        extern  printAttr
        extern  wyz_play_song
        extern  wyz_player_stop

        public  pressJumpMsg
        public  titleScreen

        section BANK_5
        binary  "title.scr"

        section CODE_5
        include "defs.inc"

titleScreen:
        ;
        ; Start the title song
        ;
        ld      a, TITLE_MUSIC
        call    wyz_play_song

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

        call    wyz_player_stop

        ret

        section RODATA_5
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
