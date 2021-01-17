        extern  _levels

        public  _initItems

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


