        extern  _updateDirection
        extern  printAttr
        extern  wyz_play_song

        public  pressJumpMsg
        public  titleScreen

        section CODE_4
        #include    "defs.inc"

titleScreen:
        border  1
        ;
        ; Start the title song
        ;
        di
        ld      a, TITLE_MUSIC
        call    wyz_play_song
        ei

        ;
        ; Display the continue message
        ;
        ld      bc, 0x1305
        ld      hl, pressJumpMsg
        ld      a, PAPER_BLACK|INK_RED|BRIGHT|FLASH
        bcall   printAttr
waitJump:
        halt
        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      z, waitJump
waitJumpRelease:
        call    _updateDirection
        ld      a, e
        and     JUMP
        jr      nz, waitJumpRelease

        ret

        section RODATA_4
pressJumpMsg:
        db      "Press Jump to Continue", 0x00
