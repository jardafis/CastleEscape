        extern  _levels
        extern  _screenTab
        extern  _tile0
		extern	_tileMapX
		extern	_xPos
		extern	_yPos
		extern  _addScore
        extern  _displayScore
        extern	clearAttr
        extern	clearChar

        public  _initCoins
        public  _animateCoins
        public  _coinTables
        public	setCurrentCoinTable
		public	checkCoinCollision
		public	removeCollectedCoins

        include "defs.asm"

		defc	COIN_WIDTH			= 0x07
		defc	COIN_HEIGHT			= 0x07

        section code_user
        ;
        ; Initialize the coin tables. This routine is called once
        ; at the start of each game to initialize the coin tables.
        ;
        ; The routine scans each level from top right to bottom left
        ; building up a table of coins for each level. These tables
        ; are then used by the coin animation routines and the coin
        ; collision routine.
        ;
_initCoins:
        pushall 

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
        ld      (ix+coinCount), 0
        ld      hl,coins
        ld      (currentCoin),hl
        ld      hl,_coinTables
        ld      (currentCoinTable),hl

        ld      hl,_levels
.levelYLoop
        ld      (currentLevel), hl
        ld      (ix+levelX), MAX_LEVEL_X

.levelXLoop
        ld      hl,(currentCoinTable)
        ld      de,(currentCoin)
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      (currentCoinTable),hl

        ld      hl,(currentLevel)
        ld      (ix+tileY), 0
        ld      c,SCREEN_HEIGHT

.tileYLoop
        ld      (ix+tileX), 0
        ld      b,SCREEN_WIDTH

.tileXLoop
        ld      a,(hl)                  ; Get tile ID
		cmp		ID_COIN
        call    z,addCoin
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

        ld      de,(currentCoin)
        ; Flags, 0xff = end of list
        ld      a,0xff
        ld      (de),a
        inc     de
        ld      (currentCoin),de

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
.addCoin
        ld      de,(currentCoin)

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
        ld      a,(ix+coinCount)
        inc     (ix+coinCount)
        ld      (de),a
        inc     de

        ld      (currentCoin),de

        ret     


        ;
        ; On entry
        ;		hl - pointer to coin table for current level
_animateCoins:
;        ex      af,af'
;        push    hl
;        exx
;        pop     hl

		ld		hl,(currentCoinTable)
.nextCoin
        ld      a,(hl)                  ; Coin flags
        cp      0xff
        jr      z,endOfList

        cp      0x01                    ; Is the coin visible?
        jr      nz,notVisible
        inc     hl


        ; Calculate the screen address
        ld      c,(hl)                  ; X screen position
        inc     hl
        push    hl                      ; Save coin table pointer

        ld      l,(hl)                  ; Y screen position
        ld      h,0
        hlx     16
        ld      de,_screenTab
        add     hl,de
        ld      a,(hl)
        add     c                       ; Add X offset
        ld      c,a                     ; Store result in 'c'
        inc     hl
        ld      b,(hl)

        pop     hl                      ; Restore coin table pointer
        inc     hl

        ; Calculate the tile address using the animation index
        ld      a,(hl)                  ; Animation index
        and     0x03                    ; Only 4 animations 0-3
        add     ID_COIN                 ; Index of first animation
        inc     (hl)                    ; Increment animation index for next time
        inc     hl

        push    hl                      ; Save coin table pointer

        ld      l,a
        ld      h,0
        hlx     8
        ld      de,_tile0
        add     hl,de

        ; Display the tile. We are going to use the
        ; stack pointer to load a 16 bit value so
        ; we need to disable interrupts.
        di      
        ; Save the current stack pointer
        ld      (animateTempSP),sp
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
.animateTempSP = $+1
        ld      sp,0x0000
        ei      

        pop     hl                      ; Restore coin table pointer
        jp      nextCoin

.notVisible
        ld      a,SIZEOF_coin
        addhl   
        jp      nextCoin

.endOfList
;        exx
;        ex      af,af'
        ret     

setCurrentCoinTable:
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
		ld		de,_coinTables
		add		hl,de
		ld		e,(hl)
		inc		hl
		ld		d,(hl)
		ld		(currentCoinTable),de
		ret

checkCoinCollision:
		ld		hl,(currentCoinTable)
.nextCoin2
		ld		a,(hl)
        cp      0xff
        ret		z

        cp      0x01                    ; Is the coin visible?
        jr      nz,notVisible2

		push	hl
		inc		hl

		;
		; Collision check here
		;
		ld		a,(hl)					; Coin X byte position
		rlca							; x2
		rlca							; x4
		rlca							; x8
		and		%11111000				; Coin left side pixel offset
		ld		b,a
		add		COIN_WIDTH-1			; Coin right side pixel offset
		ld		c,a

		ld		a,(_xPos)				; Player left side pixel position
		inc		a
		cp		c						; Compare with coin right side
		jr		nc,blah					; 'nc' if 'c' <= 'a'

		add		PLAYER_WIDTH-4			; Get right side pixel position
		cp		b						; Compare with coin left side
		jr		c,blah					; 'c' if 'b' > 'a'

		inc		hl
		ld		a,(hl)					; Coin Y byte position
		rlca							; x2
		rlca							; x4
		rlca							; x8
		and		%11111000
		ld		b,a						; Coin top pixel position
		add		COIN_HEIGHT-1			; Coin bottom pixel offset
		ld		c,a

		ld		a,(_yPos)
		cp		c						; Compare with coin bottom
		jr		nc,blah					; 'nc' if 'c' <= 'a'

		add		PLAYER_HEIGHT-1			; Player bottom pixel position
		cp		b						; Compare with coin top
		jr		c,blah					; 'c' if 'b' > 'a'

		ld		b,(hl)					; Coin Y position
		dec		hl						; Back to the coin flags
		ld		c,(hl)					; Coin X position
		dec		hl
		xor		a						; Zero flags
		ld		(hl),a

		push	bc
		call	clearAttr
		pop		bc
		call	clearChar

		;
		; Add 5 to the score and re-display the score
		;
		ld		l,5
		call	_addScore
		call	_displayScore
.blah
		pop		hl
.notVisible2
        ld      a,SIZEOF_coin
        addhl
        jp      nextCoin2

removeCollectedCoins:
		ld		hl,(currentCoinTable)
.nextCoin3
		ld		a,(hl)
        cp      0xff
        ret		z

		or		a
        jr      nz,visible

		push	hl
		inc		hl

		ld		c,(hl)					; Coin X position
		inc		hl
		ld		b,(hl)					; Coin Y position
		push	bc
		call	clearAttr
		pop		bc
		call	clearChar

		pop		hl
.visible
        ld      a,SIZEOF_coin
        addhl
        jp      nextCoin3

		defvars 0                             ; Define the stack variables used
		{
			levelX			ds.b	1
			levelY			ds.b	1
			tileX			ds.b	1
			tileY			ds.b	1
			coinCount		ds.b	1
			SIZEOF_vars
		}

		defvars 0
		{
			coinFlags		ds.b	1
			coinX			ds.b	1
			coinY			ds.b	1
			coinFrame		ds.b	1
			SIZEOF_coin
		}

        section bss_user
.currentLevel		dw		0
.currentCoin		dw		0
.currentCoinTable	dw		0

_coinTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

.coins
		ds		SIZEOF_coin * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
