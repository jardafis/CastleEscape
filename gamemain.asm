		extern	_cls
		extern	_initISR
		extern	_border
		extern	_initCoins
		extern	_scrollInit
		extern	_scrollReset
		extern	_scroll
		extern	_initScore
		extern	_levels
		extern	_displayScreen
		extern	_displayScore
		extern	_updateDirection
		extern	_lanternFlicker
		extern	_lanternList
		extern	_copyScreen
		extern	_pasteScreen
		extern	ticks
		public	_gameMain
		public	_currentTileMap
		public	_setCurrentTileMap
		public	_mul_hla
		public	_tileMapX
		public	_tileMapY
		public	_setupScreen
		public	_gameLoop
		public	_direction
		public	_xPos
		public	_yPos
		public	_spriteBuffer

		include	"defs.asm"

		defc	START_X		= 40
		defc	START_Y		= 120

		section	code_user
_gameMain:
		pushall
		call	init

		call	newGame
.gameLoop
		;
		; Wait for refresh interrupt
		;
		halt

;		jp		gameLoop

		popall
		ret

.init
		;
		; Init ISR handling
		;
		call	_initISR

		;
		; Clear the screen and set the border color
		;
		ld		l,INK_WHITE | PAPER_BLACK
		call	_cls
		ld		l,INK_BLACK
		call	_border

		ret

.newGame
		;
		; Starting X and Y player position
		;
		ld		hl,START_X
		ld		(_xPos),hl
		ld		hl,START_Y
		ld		(_yPos),hl

		;
		; Setup the coin tables
		;
		call	_initCoins

		;
		; Setup the scrolling message
		;
		ld		l,0
		ld		h,l
		call	_scrollInit

		;
		; Initialize the core to 0
		;
		call	_initScore

		;
		; Set the current tilemap
		;
		xor		a
		ld		(_tileMapX),a
		ld		(_tileMapY),a
		call	_setCurrentTileMap

		call	_setupScreen

		ld		hl,_spriteBuffer
		push	hl
		ld		a,(_xPos)
		ld		l,a
		ld		a,(_yPos)
		ld		h,a
		push	hl

		call	_copyScreen

		pop		hl
		pop		hl
		ret

_gameLoop:
		pushall
		
		;
		; Wait for refresh interrupt
		;
;		halt
		ld		a,(ticks)
		ld		b,a
.wait
		push	af
		push	bc
		call	_updateDirection
		pop		bc
		pop		af
		ld		a,(ticks)
		cp		b
		jr		z,wait

		ld		l,INK_RED
		call	_border

		;
		; Update the scrolling message
		;
		call	_scroll

		;
		; Read the keyboard and update the direction flags
		;
		call	_updateDirection

		;
		; Flicker any lanterns on the screen
		;
		ld		hl,_lanternList
		call	_lanternFlicker

		;
		; Re-draw the screen at the players current location
		;
		ld		hl,_spriteBuffer
		push	hl
		ld		a,(_xPos)
		ld		l,a
		ld		a,(_yPos)
		ld		h,a
		push	hl
		call	_pasteScreen
		pop		hl
		pop		hl


		popall
		ret

_setupScreen:
		pushall

		ld		l,INK_WHITE | PAPER_BLACK
		call	_cls

		ld		hl,(_currentTileMap)
		call	_displayScreen

		call	_displayScore
		call	_scrollReset

		popall
		ret

_setCurrentTileMap:
		ld		a,(_tileMapY)
		ld		hl, TILEMAP_WIDTH * TILEMAP_HEIGHT
		call	_mul_hla

		ex		de,hl

		ld		a,(_tileMapX)
		ld		hl,SCREEN_WIDTH
		call	_mul_hla

		add		hl,de

		ld		de,_levels
		add		hl,de

		ld		(_currentTileMap),hl

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
		push	bc
		push	de

		ex		de,hl					; Save hl in de
		ld		hl,0
		or		a						; If multiplying by 0, result is zero
		jr		z,mulDone

		ld		b,8
.nextMul
		add		hl,hl
		rlca
		jr		nc,noAdd
		add		hl,de
.noAdd
		djnz	nextMul

.mulDone
		pop		de
		pop		bc
		ret


		section	bss_user
_currentTileMap:
		dw		0
_tileMapX:
		db		0
_tileMapY:
		db		0
_direction:
		db		0
_xPos:
		dw		0
_yPos:
		dw		0
_spriteBuffer:
		ds		16
