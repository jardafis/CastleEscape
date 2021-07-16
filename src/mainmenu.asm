        extern  _animateCoins
        extern  _attribEdit
        extern  _lanternFlicker
        extern  _tile0
        extern  _tileAttr
        extern  bank7Screen
        extern  currentCoinTable
        extern  defineKeys
        extern  keyboardScan
        extern  kjPresent
        extern  newGame
        extern  readKempston
        extern  wyz_play_song
        extern  wyz_player_stop

        public  animateMenu
        public  mainMenu
        public  rotateCount
        public  rotateCount
        public  waitReleaseKey

        section CODE_5

        include "defs.inc"

        defc    BORDER_COLOR=INK_YELLOW
        ;
        ; Display the game main menu. Options to configure and start
        ; the game are on this screen.
        ;
mainMenu:
        ;
        ; Start main menu song
        ;
        ld      a, MAIN_MENU_MUSIC
        call    wyz_play_song

displayScreen:
        ;
        ; Setup the coin table for the main menu
        ;
        ld      hl, coinTable
        ld      (currentCoinTable), hl

        ;
        ; Patch the displayTile routine to access
        ; memory @ 0xc000
        ;
        ld      a, SCREEN1_START>>8
        ld      (bank7Screen+1), a

        ;
        ; Point the ULA at screen 1
        ;
        screen  1

        ;
        ; Page in the memory bank with the main menu screen
        ; to 0xc000
        ;
        bank    7
getKey:
        ld      hl, lanternList
        call    animateMenu

        call    keyboardScan            ; Read the keyboard
        jr      nz, keyPressed          ; Process key press

        ld      a, (kjPresent)          ; Check if the kempston joystick
        or      a                       ; is present, if not
        jr      z, getKey               ; continue polling.

        ld      e, 0                    ; No direction keys pressed
        call    readKempston            ; Read the joystick
        ld      a, e                    ; Check if fire has been pressed
        and     JUMP
        jr      z, getKey               ; If not, continue polling

        ld      a, '0'                  ; Force '0'
        jr      jumpPressed
keyPressed:
        ld      hl, lanternList
        call    waitReleaseKey
jumpPressed:
        cp      '0'
        jr      z, play
        cp      '1'
        call    z, defineKeys
IFDEF   ATTRIB_EDIT
        cp      '2'
        jr      z, attribEdit
ENDIF
        jp      displayScreen

        ;
        ; Animate the menu items.
        ;
        ;   Input:
        ;       hl - Pointer to lantern list
        ;
        ;   Notes:
        ;       'hl' is preserved.
        ;
animateMenu:
        push    hl
        halt

        call    _lanternFlicker

        ld      hl, rotateCount
        dec     (hl)
        jp      p, noRotate
        ld      (hl), ROTATE_COUNT
        call    _animateCoins
noRotate:
        pop     hl
        ret

        ;
        ; Wait for a key to be released and animate the menu items.
        ;
        ;   Input:
        ;       hl - Pointer to the lantern list
        ;
        ;   Notes:
        ;       'af' is preserved.
waitReleaseKey:
        push    af
releaseKey:
        call    animateMenu
        call    keyboardScan            ; Read the keyboard
        jr      nz, releaseKey          ; Key is being pressed
        pop     af
        ret

        ;
        ; Wrapper to call attribute edit function in 'C'
        ;
attribEdit:
        ;
        ; Page bank 0 to 0xc000 since it has the attributes
        ;
        bank    0
        screen  0
        ;
        ; Patch the displayTile routine to access
        ; memory @ 0x4000
        ;
        ld      a, SCREEN_START>>8
        ld      (bank7Screen+1), a

        ld      hl, _tile0
        push    hl
        ld      hl, _tileAttr
        push    hl
        call    _attribEdit
        pop     hl
        pop     hl

        jp      displayScreen

        ;
        ; Stop menu music and start a new game. Upon return
        ; restart menu music.
        ;
play:
        call    wyz_player_stop

        call    newGame

        ld      a, MAIN_MENU_MUSIC
        call    wyz_play_song

        jp      mainMenu

        section BSS_5

        ;
        ; Counter so coins are not rotated every frame
        ;
rotateCount:
        ds      1

        section RODATA_5
        ;
        ; List of lanterns on the main menu
        ;
lanternList:
        db      4
        dw      0x8000+SCREEN_ATTR_START+(7*32)+12
        dw      0x8000+SCREEN_ATTR_START+(7*32)+13
        dw      0x8000+SCREEN_ATTR_START+(7*32)+18
        dw      0x8000+SCREEN_ATTR_START+(7*32)+19

        ;
        ; List of coins on the main menu
        ; Specified by y/x pixel addresses
        ;
coinTable:
        db      0x01, 0x16*8, 0x06*8, 0x00
        db      0x01, 0x17*8, 0x06*8, 0x01
        db      0x01, 0x18*8, 0x08*8, 0x02
        db      0xff
