        extern  bannerData
        extern  _border
        extern  _cls
        extern  _keyboardScan
        extern  displayTile
        extern  setAttr

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

getKey:
        call    _keyboardScan
        ld      a, l
        cp      10
        jr      nz, getKey

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
		; Display a screen row of tile data
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
