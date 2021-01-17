        extern  _cls
        extern  _initISR
        extern  _border
        extern  _initItems
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
		extern	_displaySprite
        extern  ticks
		extern	playerSprite
        extern	_LeftSprite0
        extern	_RightSprite0
		extern	checkXCol
		extern	checkYCol
		extern	_coinTables
		extern	coins
		extern	_animateCoins
		extern	setCurrentCoinTable
		extern	checkCoinCollision
		extern	displayCoinAttr
        public  _gameMain
        public  _currentTileMap
        public  _setCurrentTileMap
        public  _mul_hla
        public  _tileMapX
        public  _tileMapY
        public  setupScreen
        public  _gameLoop
        public  _xPos
        public  _yPos
        public  _xSpeed
        public  _ySpeed
        public  _spriteBuffer
        public  _jumping
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

		;
		; Initial coin rotate counter
		;
		ld		a,6
		ld		(coinRotate),a

        ;
        ; Setup the coin tables
        ;
		ld		hl,_coinTables
		ld		de,coins
        ld		a,ID_COIN
        call    _initItems

        ;
        ; Setup the scrolling message
        ;
        ld      hl,0
        call    _scrollInit

        ;
        ; Initialize the core to 0
        ;
        call    _initScore


        call    setupScreen

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


	IF	0
		ld		b,255
.lo
		push	af
		pop		af
		push	af
		pop		af
		djnz	lo
	ENDIF


        ld      l,INK_BLUE
        call    _border

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



        ld      l,INK_RED
        call    _border

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

        ld      l,INK_MAGENTA
        call    _border

		call	checkYCol

		;
		; If player is moving left or right, check for collisions.
		;
        ld      l,INK_GREEN
        call    _border
		ld		a,(_xSpeed)				; If xSpeed != 0 player is moving
		or		a						; left or right.
		call	nz,checkXCol			; Check for a collision.


        ;
        ; Update the scrolling message
        ;
        ld      l,INK_CYAN
        call    _border
        call    _scroll

		call	checkCoinCollision

        ld      l,INK_WHITE
        call    _border
		ld		hl,coinRotate
		dec		(hl)
		jr		nz,noRotate

		ld		a,6						; Reset rotate counter
		ld		(hl),a

		call	_animateCoins

.noRotate
        ld      l,INK_BLUE
        call    _border
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

        ld      l,INK_RED
        call    _border

		ld		a,(_xPos)
		ld		h,a
		ld		a,(_yPos)
		ld		l,a
		call	_displaySprite

        ;
        ; Flicker any lanterns on the screen
        ;
        ld      l,INK_YELLOW
        call    _border
        ld      hl,_lanternList
        call    _lanternFlicker

		; Date: 1/15/2021 Time: 10:08pm
		;
		; Check for collisions with coins. But how? Sigh! :(
		;
		; For items that are collected by the player... Coins, eggs, hearts...
		;
		; Calculate the items center pixel x,y coordinates. Basically this
		; is their x,y character position x 8 and then add 4 to x and y to
		; get the center of the character.
		;
		; Then calculate the same for the player. We can store and use the player
		; coordinates for all player/item collision checking.
		;
		; Using these 4 values, calculate the distance between the two objects
		; with the following algorithm.
		;
		; 		a = x1 - x2;		// Easy
		;		b = y1 - y2;		// Easy
		;		c = sqrt((a * a) + (b * b));		// How?
		;
		; 'c' is the distance between the objects. If 'c' < (some value, like 4, or 6) there is a colision.
		;
		;	How to do a sqrt? Can be done in Z80
		;	How long will it take? Way too slow ~360 cycles per sqrt.
		;
		;	Use pixel box collision detection instead. 8x8 box in the center of the player comapred with
		; 	a 4x4 box in the center of the 8x8 item. If the boxes overlap there is a collision.
		;

        ld      l,INK_BLACK
        call    _border

        popall  
        ret     

.getCoin
		ld		l,0x05
		call	_addScore
		call	_displayScore
		ret

setupScreen:
        pushall 

        ld      l,INK_WHITE | PAPER_BLACK
        call    _cls

		call	setCurrentCoinTable

        call    _setCurrentTileMap

		halt

        ld      hl,(_currentTileMap)
        call    _displayScreen

		call	displayCoinAttr

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
coinRotate:
		db		0
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
