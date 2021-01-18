        extern  _screenTab
        extern  _tile0
		extern	_tileMapX
		extern	_xPos
		extern	_yPos
		extern  _addScore
        extern  _displayScore
        extern	clearAttr
        extern	clearChar
		extern	_tileAttr
		extern	setAttr

        public  _animateCoins
        public  _coinTables
        public  coins
		public	checkCoinCollision
		public	currentCoinTable

        include "defs.asm"

		defc	COIN_WIDTH			= 0x07
		defc	COIN_HEIGHT			= 0x07

        section code_user

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
        ld      a,SIZEOF_item
        addhl   
        jp      nextCoin

.endOfList
;        exx
;        ex      af,af'
        ret     

		;
		; Check if the player has collided with a coin. And if so,
		; remove the coin from the level and increase and re-display
		; the score.
		;
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
		; Add 5 to the score and display it
		;
		ld		l,5
		call	_addScore
		call	_displayScore
.blah
		pop		hl
.notVisible2
        ld      a,SIZEOF_item
        addhl
        jp      nextCoin2

        section bss_user

.currentCoinTable	dw		0

_coinTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

coins:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
