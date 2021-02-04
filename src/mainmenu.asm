        extern  bannerData
        extern  _border
        extern  _cls
        extern  displayTile
        extern  setAttr
        extern  print
        extern  _attribEdit
        extern  _tile0
        extern  _tileAttr
        extern  waitKey
        extern	newGame


        public  mainMenu

        section code_user

        include "defs.asm"

        defc    BORDER_COLOR=INK_YELLOW
		;
		; Display the game main menu. Options to configure and start
		; the game are on this screen.
		;
mainMenu:
		;
        ; Clear the screen and set the border color
        ;
        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls
        ld      l, INK_BLACK
        call    _border

        halt    

        call    displayBorder

        ld      hl, opts
        ld      b, (hl)                 ; Count of menu options
        inc     hl
printOpt:
        push    bc                      ; Save loop counter

        ld      c, (hl)                 ; Screen X starting position
        inc     hl
        ld      b, (hl)                 ; Screen Y starting position
        inc     hl
        call    print                   ; Display the string

        pop     bc                      ; Restore loop counter
        djnz    printOpt

getKey:
        call    waitKey

        cp      '1'
        call    z, noop

        cp      '2'
        call    z, noop

        cp      '3'
        jr      nz, opt0
        ld      hl, _tileAttr
        push    hl
        ld      hl, _tile0
        push    hl
        call    _attribEdit
        pop     hl
        pop     hl

opt0:
        cp      '0'
        call    z, newGame

        jr      mainMenu
startGame:

        ret     

displayBorder:
        ld      hl, bannerData
        ld      de, 0x0000              ; Starting Y/X position
        call    displayRow

        ld      hl, bannerData+0x40
        ld      de, 0x1700              ; Starting Y/X position
        call    displayRow

        ld      b, SCREEN_HEIGHT-2
        ld      d, 0x01                 ; Starting Y position
sides:
        push    bc                      ; Save the loop counter

        ld      b, d                    ; Set Y position for displayTile

        ld      c, 0x00
        ld      a, 10*12                ; Left side tile ID
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile

        ld      c, SCREEN_WIDTH-1
        ld      a, 10*12+5              ; Right side tile ID
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile

        inc     d                       ; Increment Y screen position

        pop     bc                      ; Restore the loop counter
        djnz    sides

        ret     

		;
		; Display a row of tile data
		;
		;	Entry:
		;		hl - Pointer to tile data
		;		b  - Start screen Y position
		;		c  - Start screen X position
		;
displayRow:
        push    af
        push    bc
        push    de
        push    hl

        ld      b, SCREEN_WIDTH
display:
        push    bc

        ld      a, (hl)                 ; Get the tile ID
        inc     hl                      ; Point to next tile ID
        ld      bc, de                  ; Set Y/X position for displayTile
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile
        inc     e                       ; Increment X screen position

        pop     bc
        djnz    display

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

		;
		; Dummy screen to be displayed when options are selected from main menu.
		;
noop:
		;
        ; Clear the screen and set the border color
        ;
        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls
        ld      l, INK_BLACK
        call    _border

        halt    

        call    displayBorder

        ld      bc, 0x0c03
        ld      hl, dummy
        call    print

        call    waitKey

        ret     

        section rodata_user
opts:   db      4
        db      0x06, 0x0a, "0 - Start Game", 0x00
        db      0x06, 0x0c, "1 - Redefine Keys", 0x00
        db      0x06, 0x0e, "2 - Difficulty Level", 0x00
        db      0x06, 0x10, "3 - Edit Tile Attrib.", 0x00

dummy:  db      "NOP Press any key to return", 0x00
