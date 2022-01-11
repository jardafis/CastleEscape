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
        public  flickerMenu
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
        ; Bank7 holds the main menu screen
        ;
        bank    7

		; Clear the lightning by setting paper and ink colors the same
        ld      a, PAPER_BLUE|INK_BLUE
        ld      hl, lightningAttribs+3
        call    setFlicker
        ld      hl, lightningAttribs2+3
        call    setFlicker
getKey:
        halt
        call    flickerMenu

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
        call    z, defineKeys
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

flickerMenu:
        ld      hl, lightAttribs
        call    doFlicker
        ld      hl, lightAttribs2
        call    doFlicker
        ld      hl, lightningAttribs
        call    doFlicker
        ld      hl, lightningAttribs2
        call    doFlicker
        ret

		;
		; Flicker attributes
		;
		; Used to flicker lightning and lights on the main menu
		;
		; Input:
		;	hl - Pointer to the flicker table.
		;
		; Output:
		;	None.
		;
doFlicker:
        ld      a, (hl)
        dec     a
        jr      nz, skipRand
        push    hl
nextRand:
        call    rand
        ld      a, l
        and     0x7f
        jr      z, nextRand
        pop     hl
skipRand:
        ld      (hl), a                 ; Count
        inc     hl
        cp      4
        jr      c, flicker

        ld      a, (hl)                 ; Off color
        inc     hl
        inc     hl
        call    setFlicker

        ret

flicker:
        inc     hl
        ld      a, (hl)                 ; On color
        inc     hl
setFlicker:
        ld      b, (hl)                 ; Table size
        inc     hl
nextAttrib:
        push    bc

        ld      b, (hl)
        inc     hl
        ld      c, (hl)
        inc     hl

		; Check which screen bank is being used
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

        pop     bc
        djnz    nextAttrib
        ret

IF  !_ZXN
        section DATA_5
ELSE
        section DATA_2
ENDIF
lightningAttribs:
        db      0x00
        db      PAPER_BLUE|INK_BLUE     ; Off
        db      PAPER_BLUE|INK_WHITE    ; On
        db      (lightningAttribsEnd-lightningAttribs-4)/2
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
        db      0x10
        db      PAPER_BLUE|INK_BLUE     ; Off
        db      PAPER_BLUE|INK_WHITE    ; On
        db      (lightningAttribsEnd2-lightningAttribs2-4)/2
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

lightAttribs:
        db      0x20
        db      PAPER_BLACK|INK_YELLOW|BRIGHT
        db      PAPER_BLACK|INK_BLACK
        db      (lightAttribsEnd-lightAttribs-4)/2
        db      15, 29
lightAttribsEnd:

lightAttribs2:
        db      0x30
        db      PAPER_BLACK|INK_YELLOW|BRIGHT
        db      PAPER_BLACK|INK_BLACK
        db      (lightAttribsEnd2-lightAttribs2-4)/2
        db      12, 12
        db      12, 13
lightAttribsEnd2:
