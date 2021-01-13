        extern  _cls
        extern  _initISR
        extern  _border
        extern  _initCoins
        extern  _scrollInit
        extern  _scrollReset
        extern  _scroll
        extern  _initScore
        extern  _levels
        extern  _displayScreen
        extern  _displayScore
        extern  _updateDirection
        extern	_addScore
        extern  _lanternFlicker
        extern  _lanternList
        extern  _copyScreen
        extern  _pasteScreen
        extern  ticks
		extern	playerSprite
        extern	_LeftSprite0
        extern	_RightSprite0
        public  _gameMain
        public  _currentTileMap
        public  _setCurrentTileMap
        public  _mul_hla
        public  _tileMapX
        public  _tileMapY
        public  _setupScreen
        public  _gameLoop
        public  _xPos
        public  _yPos
        public  _xSpeed
        public  _ySpeed
        public  _jumping
        public  _spriteBuffer
        public  _falling

        include "defs.asm"

        defc    START_X		= 40
        defc    START_Y		= 120

        section code_user
_gameMain:
        pushall 
        call    init

        call    newGame
.gameLoop
        ;
        ; Wait for refresh interrupt
        ;
        halt    

		;		call	_gameLoop
        ;		jp		gameLoop

        popall  
        ret     

.init
        ;
        ; Init ISR handling
        ;
        call    _initISR

        ;
        ; Clear the screen and set the border color
        ;
        ld      l,INK_WHITE | PAPER_BLACK
        call    _cls
        ld      l,INK_BLACK
        call    _border

        ret     

.newGame
		;
		; Set the initial player sprite
		;
        ld		hl,_RightSprite0
        ld		(playerSprite),hl

        ;
        ; Starting X and Y player position
        ;
        ld      hl,START_X
        ld      (_xPos),hl
        ld      hl,START_Y
        ld      (_yPos),hl

        ;
        ; Initialize the X/Y speed variables
        ;
        xor     a
        ld      (_xSpeed),a
        ld      (_ySpeed),a
        ld      (_jumping),a
        ld      (_falling),a
        ;
        ; Set the current tilemap
        ;
        ld      (_tileMapX),a
        ld      (_tileMapY),a
        call    _setCurrentTileMap

        ;
        ; Setup the coin tables
        ;
        call    _initCoins

        ;
        ; Setup the scrolling message
        ;
        ld      hl,0
        call    _scrollInit

        ;
        ; Initialize the core to 0
        ;
        call    _initScore


        call    _setupScreen

        ld      hl,_spriteBuffer
        push    hl
        ld      a,(_xPos)
        ld      l,a
        ld      a,(_yPos)
        ld      h,a
        push    hl

        call    _copyScreen

        pop     hl
        pop     hl
        ret     

_gameLoop:
        pushall 
		
        ;
        ; Wait for refresh interrupt
        ;
        ;		halt
        ld      a,(ticks)
        ld      b,a
.wait
        push    bc                      ; Save 'b'
        call    _updateDirection
        pop     bc                      ; Restore 'b'
        ld      a,(ticks)               ; Get the latest 'ticks' value
        cp      b                       ; Has it changed?
        jr      z,wait                  ; If not, keep looping

        ;
        ; Re-draw the screen at the players current location
        ;
        ld      hl,_spriteBuffer
        push    hl
        ld      a,(_xPos)
        ld      l,a
        ld      a,(_yPos)
        ld      h,a
        push    hl
        call    _pasteScreen
        pop     hl
        pop     hl

        ;
        ; Handle the keyboard input from the user
        ; 'e' should contain the direction bits from
        ; the call to _updateDirection above.
        ;

        ;
        ; Update the X speed based on the user input
        ;
        bit     LEFT_BIT,e
        jr      z,checkRight
        ld      a,LEFT_SPEED
        ld		hl,_LeftSprite0
        ld		(playerSprite),hl
        jr      updateXSpeedDone
.checkRight
        bit     RIGHT_BIT,e
        jr      z,noXMovement
        ld      a,RIGHT_SPEED
        ld		hl,_RightSprite0
        ld		(playerSprite),hl
        jr      updateXSpeedDone
.noXMovement
        xor     a
.updateXSpeedDone
        ld      (_xSpeed),a

	IF 0 ; Enable for testing, allows movement
        bit     DOWN_BIT,e
        jr      z,checkUp
        ld      a,DOWN_SPEED
        jr      updateYSpeedDone
.checkUp
        bit     UP_BIT,e
        jr      z,noYMovement
        ld      a,UP_SPEED
        jr      updateYSpeedDone
.noYMovement
        xor     a
.updateYSpeedDone
        ld      (_ySpeed),a
	ENDIF
        ;
        ; Update the jump status
        ;
        ld      hl,(jumpFall)           ; Falling and jumping flags
        ld      a,l                     ; must be zero before
        or      h                       ; a jump can be started
        jr      nz,cantJump              ; If nz, falling or jumping are non-zero

        bit     JUMP_BIT,e
        jr      z,cantJump
        ld      a,JUMP_SPEED
        ld      (_ySpeed),a
        ld      a,JUMP_HEIGHT * 2
        ld      (_jumping),a
.cantJump

		ld		a,(_jumping)
		or		a
		jz		_2F
		ld		e,a						; Save the jump counter
		cp		JUMP_HEIGHT
		jr		nz,_1F
		ld		a,-JUMP_SPEED
        ld      (_ySpeed),a
_1F
		ld		a,e						; Restore jump counter
		dec		a
		ld		(_jumping),a
_2F

;		jp		checkX

	IF 1
		ld		a,(_ySpeed)
		or		a
		jp		m,checkX					; If 'a' is negative (m) player is going up
		;
		; ySpeed is positive player is moving down
		;
	IF 0
		;
		; Check if the new Y position puts the player off the bottom
		; of the screen and change the level accordingly.
		;
		ld		hl,(_yPos)				; Get the Y pixel offset
;		ld		a,(_ySpeed)				; 'a' still holds _ySpeed from above
		add		l						; add Y pixel offset
		cp		MAX_Y_POS - PLAYER_HEIGHT
		jr		c,_4F					; a < (MAX_Y_POS - PLAYER_HEIGHT)
		; else a >= (MAX_Y_POS - PLAYER_HEIGHT)
		ld		hl,_tileMapY
		inc		(hl)
		ld		a,24
		ld		(_yPos),a
		call	_setCurrentTileMap
		call	_setupScreen
	ENDIF
		ld		hl,(_yPos)
_4F
		; if ((currentTileMap[(((yPos + PLAYER_HEIGHT) >> 3) * 64) + (xPos >> 3)] >= 144)
		;  || (currentTileMap[(((yPos + PLAYER_HEIGHT) >> 3) * 64) + ((xPos + (PLAYER_WIDTH - 1)) >> 3)] >= 144))
		ld		a,PLAYER_HEIGHT
		addhl							; 'hl' is now the offset of the pixel row below the player
		ld		a,l
		and		%11111000				; Remove the pixel offset within the byte (lower 3 bits)
		ld		l,a
		hlx		8						; Divide by 8 to get byte offset and multiply by 64 (width of tilemap)

		ld		a,(_xPos)				; Get the X pixel offset
		ld		b,a						; Save pixel offset for later
		rrca							; Divide by 8 to get the byte offset
		rrca							; Faster to do rrca followed by AND rather than srl
		rrca
		and		%00011111
		addhl							; Add X byte offset to tile map Y index

		ld		de,(_currentTileMap)
		add		hl,de

		ld		a,(hl)					; Get tile ID
		cp		144
		jr		nc,landed				; 'nc' if a >= 144

		inc		hl
		ld		a,(hl)					; Get tile ID
		cp		144
		jr		nc,landed				; 'nc' if a >= 144

		ld		a,b						; Restore X pixel offset
		and		%00000111				; Check if any of the lower 3 bits are set
		jr		z,gravity				; if not we are done
		inc		hl						; Check the tile to the right
		ld		a,(hl)
		cp		144
		jr		c,gravity				; 'c' if a < 144
.landed
		;
		; Reset ySpeed and jumping count and falling flag
		;
		xor		a
		ld		(_ySpeed),a
		ld		(_jumping),a
		ld		(_falling),a
		jp		checkX

.gravity
		ld		a,(_jumping)
		or		a
		jr		nz,checkX

		xor		a
		ld		(_xSpeed),a
		inc		a
		ld		(_ySpeed),a
		ld		(_falling),a

.checkX

	ENDIF

		ld		a,(_xSpeed)				; If xSpeed != 0 player is moving
		or		a						; left or right.
		call	nz,checkXCol			; Check for a collision.

        ld      l,INK_RED
        call    _border

        ;
        ; Update the scrolling message
        ;
        call    _scroll

        ;
        ; Flicker any lanterns on the screen
        ;
        ld      hl,_lanternList
        call    _lanternFlicker

        popall  
        ret     

	IF 1
.checkTop
		;
		; ySpeed is negative player is moving up
		;
		ld		hl,(_yPos)				; Get the Y pixel offset
;		ld		a,(_ySpeed)				; 'a' still holds _ySpeed from above
		add		l
		cp		24
		jr		nc,checkX				; a >= 24
		; else a < 24
		ld		hl,_tileMapY
		dec		(hl)
		ld		a,MAX_Y_POS - PLAYER_HEIGHT
		ld		(_yPos),a
		call	_setCurrentTileMap
		call	_setupScreen
		jp		checkX
	ENDIF


.checkXCol
		ld		b,a						; Save xSpeed
		ld		hl,(_yPos)				; Get the yPos and add the ySpeed
		ld		a,(_ySpeed)				; ySpeed may be positive or negative
		or		a
		jp		p,pos1					; If ySpeed is positive
		dec		h						; ySpeed is negative, subtract 1 from 'h'
.pos1
		addhl							; 'hl' holds yPos + ySpeed
		ld		c,l						; save it in 'c'

		ld		a,l
		and		%11111000				; Remove the pixel offset within the byte (lower 3 bits)
		ld		l,a
		hlx		8						; Divide by 8 and multuply by 64 -> multiply by 8

		ld		a,b						; Restore xSpeed
		or		a						; Update flags

		ld		a,(_xPos)				; Get the X pixel offset
		jp		m,checkLeftCol			; If xSpeed was negative going left, check left side
		add		PLAYER_WIDTH-1			; else, going right, check right size
.checkLeftCol
		add		b
		rrca							; Divide by 8 to get the byte offset
		rrca							; Faster to do rrca followed by AND rather than srl
		rrca
		and		%00011111
		addhl							; Add X byte offset to tile map Y index

		ld		de,(_currentTileMap)
		add		hl,de
		ld		a,(hl)
		cp		143
		ret		nc						; 'nc' if a >= 144

		; Check the bottom half of the sprite
		ld		de,TILEMAP_WIDTH
		add		hl,de
		ld		a,(hl)
		cp		143
		ret		nc						; 'nc' if a >= 144

		ld		a,c						; Restore yPos + ySpeed
		and		%00000111				; If the lower 3 bits are zero player has not shifted into
		jr		z,checkXDone			; the next row down, return.
		add		hl,de					; Next row down

		ld		a,(hl)
		cp		143
		ret		nc						; 'nc' if a >= 144

.checkXDone
		ld		a,(_xPos)				; Get the X pixel offset
		add		b
		ld		(_xPos),a

		ret

.stopX
		xor		a
		ld		(_xSpeed),a
		ret

.getCoin
		ld		l,0x05
		call	_addScore
		call	_displayScore
		ret

_setupScreen:
        pushall 

        ld      l,INK_WHITE | PAPER_BLACK
        call    _cls

        ld      hl,(_currentTileMap)
        call    _displayScreen

        call    _displayScore
        call    _scrollReset

        popall  
        ret     

_setCurrentTileMap:
        ld      a,(_tileMapY)
        ld      hl, TILEMAP_WIDTH * TILEMAP_HEIGHT
        call    _mul_hla

        ex      de,hl

        ld      a,(_tileMapX)
        ld      hl,SCREEN_WIDTH
        call    _mul_hla

        add     hl,de

        ld      de,_levels
        add     hl,de

        ld      (_currentTileMap),hl

        ret     

        ;
        ; On input:
        ;		hl - value
        ;		a  - Multiplier
        ;
        ; Output:
        ;		hl	- Product of hl and a
        ;		All other registers unchanged
        ;
_mul_hla:
        push    bc
        push    de

        ex      de,hl                   ; Save hl in de
        ld      hl,0
        or      a                       ; If multiplying by 0, result is zero
        jr      z,mulDone

        ld      b,8
.nextMul
        add     hl,hl
        rlca    
        jr      nc,noAdd
        add     hl,de
.noAdd
        djnz    nextMul

.mulDone
        pop     de
        pop     bc
        ret     

        section bss_user
_currentTileMap:
        dw		0
_tileMapX:
        db      0
_tileMapY:
        db      0
_xPos:
        dw      0
_yPos:
        dw      0
_xSpeed:
        db      0
_ySpeed:
        db      0
.jumpFall                               ; Access jumping and falling as a single word
_jumping:
        db      0
_falling:
        db      0
_spriteBuffer:
		ds		48
