        extern  _screenTab
        extern  _tile0
        extern  _lanternList
        public  _displayScreen
        public  _tileAttr

        include "defs.asm"

        ; Sprite ID's
        defc    ID_LANTERN		= 88
        defc    ID_BLANK		= 11

        section code_user
        ;
        ; Display a complete tile map
        ;
        ; On entry hl points to the tilemap to be displayed.
        ;
_displayScreen:
        ; Save the registers and setup ix to point to variable space
        pushall 

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP),sp
        ld      ix,-SIZEOF_vars
        add     ix,sp
        ld      sp,ix

        ld      de,_lanternList
        xor     a
        ld      (de),a                  ; Zero the lantern count
        inc     de
        ld      (lanternPtr),de         ; Initialize table pointer

        ; Zero out the Y character location
        ld      (ix+yPos),0

        ld      b,SCREEN_HEIGHT
.yloop
        push    bc

        ; Zero out the X character location
        ld      (ix+xPos),0

        ld      b,SCREEN_WIDTH
.xloop
        ld      a,(hl)                  ; read the tile index
        cmp		ID_BLANK                   ; Check for blank
        jr      z,nextTile              ; On to the next tile

		cmp		ID_LANTERN                       ; Check for a lantern
        call    z,addLantern

        push    bc                      ; save the loop counter
        push    hl                      ; save the tilemap pointer

        ;
        ; Get the attribute for the tile
        ;
        ld      de,_tileAttr
        ld      l,a
        ld      h,0
        ex      af,af'                  ; save tile index
        add     hl,de
        ld      c,(hl)                  ; Tile attribute in 'c'

        ;
        ; Set the attribute for the tile
        ;
        ld      l,(ix+yPos)
        ld      h,0
        hlx     16
        push    hl                      ; y * 16 - save it for later
        hlx     2
        ld      a,(ix+xPos)
        add     l
        ld      l,a
        ld      de,SCREEN_ATTR_START
        add     hl,de
        ld      (hl),c                  ; Store it to the screen

        ; Claculate the screen Y address
        pop     hl                      ; y * 16 saved above
        ld      de,_screenTab           ;                     10
        add     hl,de                   ;                         11

        ; Load the screen address into BC
        ; and add the X character position
        ld      a,(ix+xPos)             ; Get the X offset        13
        add     (hl)                    ; low order byte          7
        ld      c,a                     ; 4
        inc     hl                      ; 6
        ld      b,(hl)                  ; high order byte         7
        ;                                           Total 118

        ; Calculate the tile index address
        ex      af,af'                  ; restore tile index
        ld      l,a
        ld      h,0
        hlx     8                       ; Multuply by 8 since 8 bytes per tile
        ld      de,_tile0               ; Start of tile data
        add     hl,de

        ; Display the tile. We are going to use the
        ; stack pointer to load a 16 bit value so
        ; we need to disable interrupts.
        di      
        ; Save the current stack pointer
        ld      (displayScreenTempSP),sp
        ; Point the stack at the tile data
        ld      sp,hl
        ; Point hl at the screen address
        ld      hl,bc

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl),c                  ; 7
        inc     h                       ; Add 256 to screen address 4
        ld      (hl),b                  ; 7
        inc     h                       ; Add 256 to screen address 4

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl),c                  ; 7
        inc     h                       ; 4
        ld      (hl),b                  ; 7
        inc     h                       ; 4

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl),c                  ; 7
        inc     h                       ; 4
        ld      (hl),b                  ; 7
        inc     h                       ; 4

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl),c                  ; 7
        inc     h                       ; 4
        ld      (hl),b                  ; 7

        ; Restore the stack pointer.
.displayScreenTempSP = $+1
        ld      sp,0x0000
        ei      

        pop     hl                      ; tile map pointer
        pop     bc                      ; loop counter
.nextTile
        inc     hl                      ; next tile

        ; next x location
        inc     (ix+xPos)

        djnz    xloop

        ld      de,TILEMAP_WIDTH - SCREEN_WIDTH
        add     hl,de

        ; next y location
        inc     (ix+yPos)

        pop     bc
        djnz    yloop

.tempSP = $ + 1
        ld      sp,0x0000
        popall  
        ret     

        ;
        ; Add a lantern to the lantern list
        ; On entry:
        ;			a - Sprite ID of lantern
        ;
.addLantern
        push    af
        push    de
        push    hl

        ; Increment the lantern count
        ld      hl,_lanternList
        inc     (hl)

        ; Calculate the screen attribute address
        ld      l,(ix+yPos)
        ld      h,0
        hlx     32
        ld      a,(ix+xPos)
        add     l
        ld      l,a
        ld      de,SCREEN_ATTR_START
        add     hl,de

.lanternPtr = $ + 1
        ld      (0x0000),hl             ; Self modifying code
        ld      hl,lanternPtr
        inc     (hl)
        inc     (hl)

        pop     hl
        pop     de
        pop     af
        ret     

		defvars 0
		{
			xPos	ds.b	1
			yPos	ds.b	1
			SIZEOF_vars
		}

        section rodata_user
_tileAttr:
        binary  "attrib.dat"
