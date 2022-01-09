        extern  _animateCoins
        extern  _attribEdit
        extern  _lanternFlicker
        extern  _tile0
        extern  _tileAttr
IF  !_ZXN
        extern  bank7Screen
ELSE
        extern  clearTilemap
        extern  clearULACoinHi
        extern  clearULATileHi
ENDIF
        extern  currentCoinTable
        extern  defineKeys
        extern  keyboardScan
        extern  kjPresent
        extern  newGame
        extern  readKempston
        extern  wyz_play_song
        extern  wyz_player_stop

        public  mainMenu
        public  rotateCount
        public  rotateCount
        public  waitReleaseKey
IF  !_ZXN
        section CODE_5
ELSE
        section CODE_2
ENDIF
        #include    "defs.inc"

        defc    BORDER_COLOR=INK_YELLOW
        ;
        ; Display the game main menu. Options to configure and start
        ; the game are on this screen.
        ;
mainMenu:
        border  1
        ;
        ; Start main menu song
        ;
        di
        call    wyz_player_stop
        ld      a, MAIN_MENU_MUSIC
        call    wyz_play_song
        ei

displayScreen:
IF  _ZXN
        call    clearTilemap
ENDIF
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
        call    waitReleaseKey
jumpPressed:
        cp      '0'
        jr      z, play
        cp      '1'
        call    z, defineKeysWrapper
IFDEF   ATTRIB_EDIT
        cp      '2'
        jr      z, attribEdit
ENDIF
        jp      displayScreen

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
        call    keyboardScan            ; Read the keyboard
        jr      nz, releaseKey          ; Key is being pressed
        pop     af
        ret

IFDEF   ATTRIB_EDIT
        ;
        ; Wrapper to call attribute edit function in 'C'
        ;
attribEdit:
        ;
        ; Page bank 0 to 0xc000 since it has the attributes
        ;
        bank    0
        screen  0

        ld      hl, _tile0
        push    hl
        ld      hl, _tileAttr
        push    hl
        bcall   _attribEdit
        pop     hl
        pop     hl

        jp      displayScreen
ENDIF

play:
        call    newGame
        jp      mainMenu

defineKeysWrapper:
        jp      defineKeys

IF  !_ZXN
        section BSS_5
ELSE
        section BSS_2
ENDIF
        ;
        ; Counter so coins are not rotated every frame
        ;
rotateCount:
        ds      1
