        extern  _levels
		extern	_tileAttr
		extern	_tileMapX
		extern	_screenTab
		extern	_tile0
		extern	setAttr

        public  _initItems
        public	displayItemAttr
		public	setCurrentItemTable
		public	displayItems

		include	"defs.asm"

        section code_user
        ;
        ; Entry:
        ;		hl - Pointer to the item table
        ;		de - Pointer to the item list
        ;		a  - Tile ID of item being initialized
		;
        ; This routine scans each level from top right to bottom left
        ; building up a table of items for each level. These tables
        ; are then used by animation routines and collision routines.
        ;
_initItems:
        pushall

		;
		; Save parameters passed in registers
		;
		ld		(itemID),a
        ld      (currentItem),de
        ld      (currentItemTable),hl

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP),sp
        ld      ix,-SIZEOF_vars
        add     ix,sp
        ld      sp,ix

        ;
        ; Initialize memory variables
        ;
        ld      (ix+levelY), MAX_LEVEL_Y
        ld      (ix+itemCount), 0

        ld      hl,_levels
.levelYLoop
        ld      (currentLevel), hl
        ld      (ix+levelX), MAX_LEVEL_X

.levelXLoop
        ld      hl,(currentItemTable)
        ld      de,(currentItem)
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      (currentItemTable),hl

        ld      hl,(currentLevel)
        ld      (ix+tileY), 0
        ld      c,SCREEN_HEIGHT

.tileYLoop
        ld      (ix+tileX), 0
        ld      b,SCREEN_WIDTH

.tileXLoop
        ld      a,(hl)                  ; Get tile ID
.itemID = $ + 1
		cp		0x00
        call    z,addItem
        inc     hl
        inc     (ix+tileX)
        djnz    tileXLoop

        ; Next row in the tilemap
        ld      de,SCREEN_WIDTH * MAX_LEVEL_X - SCREEN_WIDTH
        add     hl,de

        inc     (ix+tileY)
        dec     c
        jr      nz,tileYLoop

        ;
        ; Move the current level pointer to the next level to the right
        ;
        ld      hl,(currentLevel)
        ld      de,SCREEN_WIDTH
        add     hl,de
        ld      (currentLevel),hl

        ld      de,(currentItem)
        ; Flags, 0xff = end of list
        ld      a,0xff
        ld      (de),a
        inc     de
        ld      (currentItem),de

        ;
        ; Decrement X counter and loop if not zero
        ;
        dec     (ix+levelX)
        jr      nz,levelXLoop

        ;
        ; Move the current level pointer to the next level down
        ;
        ld      hl,(currentLevel)
        ld      de,-SCREEN_WIDTH * MAX_LEVEL_X
        add     hl,de
        ld      de,SCREEN_WIDTH * MAX_LEVEL_X * SCREEN_HEIGHT
        add     hl,de
        ld      (currentLevel),hl

        ;
        ; Decrement Y counter and loop if not zero
        ;
        dec     (ix+levelY)
        jr      nz,levelYLoop

        ;
        ; Restore the stack frame
        ;
.tempSP = $ + 1
        ld      sp,0x0000

        popall
        ret

        ;
        ; Add a coin to the coin table
        ;
.addItem
        ld      de,(currentItem)

        ; Flags, Bit0 = visible
        ld      a,1
        ld      (de),a
        inc     de

        ; X screen position
        ld      a,(ix+tileX)
        ld      (de),a
        inc     de

        ; Y screen position
        ld      a,(ix+tileY)
        ld      (de),a
        inc     de

        ; Animation frame
        ld      a,(ix+itemCount)
        inc     (ix+itemCount)
        ld      (de),a
        inc     de

        ld      (currentItem),de

        ret

		;
		; Calculate the value of the current item table based
		; on the values of tileMapX and tileMapY and save it
		; in .
		;
		; Entry:
		;		hl - Pointer to current item table variable
		; 		de - Pointer to item tables
		;
setCurrentItemTable:
		ld		(currItemTab),hl
		ld		hl,(_tileMapX)			; Get tileMapX & tileMapY
		ld		a,h
		rla								; x2
		rla								; x4
		and		%11111100
		ld		h,a
		ld		a,l
		sla		a						; x2
		add		h
		ld		l,a
		ld		h,0
		add		hl,de
		ld		e,(hl)
		inc		hl
		ld		d,(hl)
.currItemTab = $ + 2
		ld		(0x0000),de
		ret

		;
		; Cycle through the specified item table if the item is
		; visible, update the screen with the attribute for the item.
		;
		; Items themsleves are not displayed here.
		;
		; Entry:
		;		hl - Pointer to the current item table
		;		a  - ID of the item
		;
displayItemAttr:
		ld		(itemID2),a
.nextItem
		ld		a,(hl)
        cp      0xff
        ret		z

		or		a
        jr      z,notVisible

		push	hl

		inc		hl
		ld		c,(hl)					; Item X position
		inc		hl
		ld		b,(hl)					; Item Y position

.itemID2 = $ + 1
		ld		a,0x00
		ld		de,_tileAttr
		addde
		ld		a,(de)

		call	setAttr

		pop		hl
.notVisible
        ld      a,SIZEOF_item
        addhl
        jr      nextItem

		;
		;
		; Entry:
		;		hl - Pointer to current item table
		;		a  - ID of item
		;
displayItems:
		ld		(itemID3),a
.nextItem2
        ld      a,(hl)                  ; Flags
        cp      0xff
        ret     z

        cp      0x00                    ; Is the item visible?
        jr      z,notVisible2

		push	hl
        inc     hl
        ; Calculate the screen address
        ld      c,(hl)                  ; X screen position
        inc     hl
        ld      l,(hl)                  ; Y screen position
        ld      h,0
        hlx     16
        ld      de,_screenTab
        add     hl,de
        ld      a,(hl)					; Screen low byte address
        add     c                       ; Add X offset
        ld      c,a                     ; Store result in 'c'
        inc     hl
        ld      b,(hl)

.itemID3 = $ + 1
        ld      l,0x00					; 0x00 is over written by the value of 'a' passed in
        ld      h,0
        hlx     8
        ld      de,_tile0
        add     hl,de

        ; Display the tile. We are going to use the
        ; stack pointer to load a 16 bit value so
        ; we need to disable interrupts.
        di
        ; Save the current stack pointer
        ld      (TempSP),sp
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
        pop     bc
        ld      (hl),c
        inc     h
        ld      (hl),b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl),c
        inc     h
        ld      (hl),b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl),c
        inc     h
        ld      (hl),b

        ; Restore the stack pointer.
.TempSP = $+1
        ld      sp,0x0000
        ei

        pop     hl                      ; Restore coin table pointer
.notVisible2
        ld      a,SIZEOF_item
        addhl
        jr      nextItem2

		section	bss_user
		defvars 0                             ; Define the stack variables used
		{
			levelX			ds.b	1
			levelY			ds.b	1
			tileX			ds.b	1
			tileY			ds.b	1
			itemCount		ds.b	1
			SIZEOF_vars
		}

.currentLevel		dw		0
.currentItem		dw		0
.currentItemTable	dw		0


