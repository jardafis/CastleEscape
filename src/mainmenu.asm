        extern  _attribEdit
        extern  _tile0
        extern  _tileAttr
IF  _ZXN
        extern  clearTilemap
ENDIF
        extern  defineKeys
        extern  keyboardScan
        extern  kjPresent
        extern  newGame
        extern  readKempston
        extern  wyz_play_song
        extern  wyz_player_stop
        extern  rand
        extern  setAttrHi
        extern  setAttr

        public  mainMenu
        public  waitReleaseKey
        public  flickerLight
        public  doLightning
        public  lightningAttribs
        public  lightningAttribs2
IF  !_ZXN
        section CODE_5
ELSE
        section CODE_2
ENDIF
        #include    "defs.inc"

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
        ld      a, PAPER_BLUE|INK_BLUE
        ld      hl, lightningAttribs+1
        call    setLightning
        ld      hl, lightningAttribs2+1
        call    setLightning
        xor     a
getKey:
        halt
        call    flickerLight
        ld      hl, lightningAttribs
        call    doLightning
        ld      hl, lightningAttribs2
        call    doLightning

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

flickerLight:
        push    af

        ld      a, (flickerCount)
        dec     a
        jr      nz, noFlicker

        call    rand
        ld      a, l
        cp      0x80
        ld      l, 0
        jr      c, lightOff
        ld      l, INK_YELLOW|BRIGHT
lightOff:
        ld      a, l

        ld      b, 15
        ld      c, 29

        ld      d, a
        ld      a, (currentBank)
        and     %0001000
        ld      a, d
        push    af
        call    z, setAttr
        pop     af
        push    af
        call    nz, setAttrHi
        pop     af

        call    rand
        ld      a, l
        and     0x07
noFlicker:
        ld      (flickerCount), a
        pop     af
        ret

doLightning:
        ld      a, (hl)
        dec     a
        jr      nz, noLightning
        push    hl
        call    rand
        ld      a, l
        pop     hl
        and     0x0f
noLightning:
        ld      (hl), a
        inc     hl
        cp      2
        jr      c, lightning

        ld      a, PAPER_BLUE|INK_BLUE
        call    setLightning

        ret

lightning:
        ld      a, PAPER_BLUE|INK_WHITE
setLightning:
        ld      b, (hl)
        inc     hl
lll:
        push    bc
        ld      b, (hl)
        inc     hl
        ld      c, (hl)
        inc     hl

        ld      d, a
        ld      a, (currentBank)
        and     %0001000
        ld      a, d
        push    af
        call    z, setAttr
        pop     af
        push    af
        call    nz, setAttrHi
        pop     af

lightningUpdated:
        pop     bc
        djnz    lll
        ret

        section RODATA_2
lightningAttribs:
        db      0
        db      (lightningAttribsEnd-lightningAttribs-2)/2
        db      0, 18, 0, 19
        db      1, 18, 1, 19, 1, 20
        db      2, 18, 2, 19, 2, 20, 2, 21
        db      3, 19, 3, 20, 3, 21
        db      4, 19, 4, 21
        db      5, 19, 5, 20, 5, 21
        db      6, 19, 6, 20
        db      7, 19, 7, 20, 7, 21
        db      8, 18, 8, 19, 8, 20, 8, 21
        db      9, 18, 9, 20
        db      10, 18, 10, 20
lightningAttribsEnd:

lightningAttribs2:
        db      0
        db      (lightningAttribsEnd2-lightningAttribs2-2)/2
        db      6, 0
        db      7, 0
        db      8, 0, 8, 1, 8, 2, 8, 3, 8, 4, 8, 5, 8, 6, 8, 7, 8, 8, 8, 9
        db      9, 2, 9, 3, 9, 4, 9, 5, 9, 8
        db      10, 2, 10, 5, 10, 6, 10, 7
        db      11, 2, 11, 3, 11, 6
        db      12, 3, 12, 4
        db      13, 3, 13, 4
        db      14, 3
lightningAttribsEnd2:

IF  !_ZXN
        section BSS_5
ELSE
        section BSS_2
ENDIF
        ;
        ; Counter so coins are not rotated every frame
        ;
flickerCount:
        ds      1
