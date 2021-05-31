        extern  _attribEdit
        extern  _tile0
        extern  _tileAttr
        extern  newGame
        extern  keyboardScan
        extern  readKempston
        extern  kjPresent
        extern  LOAD_SONG
        extern  PLAYER_OFF
        extern  _lanternFlicker
        extern  currentCoinTable
        extern  _animateCoins
        extern  bank7Screen
        extern  defineKeys

        public  mainMenu
        public  rotateCount
        public  rotateCount
        public  animateMenu
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
        LD      A, MAIN_MENU_MUSIC
        CALL    LOAD_SONG

displayScreen:
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

        ;
        ; Patch the animate coins routine to access
        ; memory @ 0xc000
        ;
        ld      hl, SET_7_B_OPCODE
        ld      (bank7Screen), hl

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
        or      a                       ; If a key has been presses
        jr      nz, keyPressed          ; jump to process it.

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
        call    z, play
        cp      '1'
        call    z, defineKeys
IFDEF   ATTRIB_EDIT
        cp      '2'
        call    z, attribEdit
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
        or      a                       ; If a key is pressed
        jr      nz, releaseKey          ; continue looping
        pop     af
        ret

        ;
        ; Wrapper to call attribute edit function in 'C'
        ;
        ;   Notes:
        ;       'af' is preserved.
attribEdit:
        push    af
        ;
        ; Page bank 0 to 0xc000 since it has the attributes
        ;
        bank    0
        screen  0

        ld      hl, _tile0
        push    hl
        ld      hl, _tileAttr
        push    hl
        call    _attribEdit
        pop     hl
        pop     hl

        pop     af
        ret

        ;
        ; Stop menu music and start a new game. Upon return
        ; restart menu music.
        ;
        ;   Notes:
        ;       'af' is preserved.
play:
        push    af

        call    PLAYER_OFF

        call    newGame

        LD      A, MAIN_MENU_MUSIC
        CALL    LOAD_SONG

        pop     af
        ret

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
