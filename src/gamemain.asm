        extern  _cls
        extern  initISR
        extern  _initItems
        extern  _scrollInit
        extern  _scroll
        extern  _levels
        extern  _updateDirection
        extern  _lanternFlicker
        extern  _lanternList
        extern  _copyScreen
        extern  _pasteScreen
        extern  _displaySprite
        extern  ticks
        extern  playerSprite
        extern  _LeftKnight0
        extern  _RightKnight0
        extern  checkXCol
        extern  checkYCol
        extern  _coinTables
        extern  coins
        extern  _animateCoins
        extern  eggTables
        extern  eggs
        extern  currentCoinTable
        extern  currentEggTable
        extern  checkItemCollision
        extern  coinCollision
        extern  eggCollision
        extern  eggCount
        extern  score
        extern  currentHeartTable
        extern  heartTables
        extern  heartCount
        extern  hearts
        extern  heartCollision
        extern  decrementEggs
        extern  _setupScreen
        extern  detectKempston
        extern  readKempston
        extern  kjScan
        extern  mainMenu
        extern  spiderTables
        extern  spiders
        extern  spiderCollision
        extern  currentSpiderTable
        extern  displayItems_pixel
        extern  updateSpiderPos
        extern  printAttr
        extern  wyz_player_init
        extern  bank7Screen
        extern  titleScreen
        extern  wyz_play_sound

        public  _currentTileMap
        public  _setCurrentTileMap
        public  _mul_hla
        public  _tileMapX
        public  _tileMapY
        public  _xPos
        public  _yPos
        public  _xSpeed
        public  _ySpeed
        public  _spriteBuffer
        public  _jumping
        public  _falling
        public  _main
        public  newGame
        public  gameOver
        public  xyPos
        public  xyStartPos
        public  startSprite

        include "defs.inc"

        section CODE_2
_main:
        call    init

        call    titleScreen

        call    mainMenu

        assert

init:
        border  INK_BLACK

		;
		; Initialize the WYZ Player
		;
        call    wyz_player_init

        ;
        ; Init ISR handling
        ;
        call    initISR

		;
		; Detect Kempston joystick and modify
		; user input scanning code to poll it.
		;
        call    detectKempston
        ret     z
        ld      a, JP_OPCODE
        ld      (kjScan), a
        ld      hl, readKempston
        ld      (kjScan+1), hl

        ret

newGame:
        ld      (gameOver+1), sp

        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls

        ld      bc, 0x0b0c
        ld      hl, readyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        call    printAttr

        ;
        ; Patch the animate coins routine to access
        ; the screen memory at 0x4000
        ;
        ld      hl, NOP_OPCODE<<8|NOP_OPCODE
        ld      (bank7Screen), hl

        ;
        ; Point the ULA at screen 0
        ;
        screen  0

		;
		; Select bank 0 @ 0xc000
		;
        bank    0

        ;
        ; Initialize the coin tables
        ;
        ld      hl, _coinTables
        ld      de, coins
        ld      a, ID_COIN
        call    _initItems
        ;
        ; Initialize the egg tables
        ;
        ld      hl, eggTables
        ld      de, eggs
        ld      a, ID_EGG
        call    _initItems
        ;
        ; Initialize the hearts tables
        ;
        ld      hl, heartTables
        ld      de, hearts
        ld      a, ID_HEART
        call    _initItems
        ;
        ; Initialize the hearts tables
        ;
        ld      hl, spiderTables
        ld      de, spiders
        ld      a, ID_SPIDER
        call    _initItems

        ;
        ; Set the initial player sprite
        ;
        ld      hl, _RightKnight0
        ld      (playerSprite), hl

        ;
        ; Starting X and Y player position
        ;
        ld      hl, START_Y<<8|START_X
        ld      (_xPos), hl

        ;
        ; Initialize the X/Y speed variables
        ;
        xor     a
        ld      (_xSpeed), a
        ld      (_ySpeed), a
        ld      (_jumping), a
        ld      (_falling), a
        ;
        ; Set the current tilemap
        ;
        ld      (_tileMapX), a
        ld      (_tileMapY), a

        ;
        ; Setup the scrolling message
        ;
        call    _scrollInit

        ;
        ; Zero score and counts
        ;
        ld      hl, 0
        ld      (score), hl
        ld      (eggCount), hl
        ld      a, START_LIVES
        ld      (heartCount), a

        call    _setupScreen

        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _copyScreen


		;
		; The game loop
		;
		; The game loop does the following basic operations.
		; * Remove any moving items from the screen at their current position
		; * Update user inputs
		; * Update the position of any moving items
		; * Re-draw any moving items at their new position
		;
gameLoop:
        ;
        ; Wait for refresh interrupt
        ;
        halt

		; ######################################
        ;
        ; Update the scrolling message
        ;
		; ######################################
        call    _scroll

		; ######################################
		;
		; Remove any moving items from the screen
		;
		; ######################################

        ;
        ; Re-draw the screen at the players current location
        ;
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _pasteScreen

        ld      a, (ticks)
        rrca
        jr      c, skipOddFrame2

		;
		; The below code is only executed on even frame numbers
		;

		;
		; Remove spiders
		;
        ld      a, ID_BLANK
        ld      hl, (currentSpiderTable)
        call    displayItems_pixel

skipOddFrame2:

		; ######################################
		;
		; Update user input
		;
		; ######################################
        call    _updateDirection

        ;
        ; Handle the keyboard input from the user
        ; 'e' should contain the direction bits from
        ; the call to _updateDirection above.
        ;

        ;
        ; Update the X speed based on the user input
        ;
        bit     LEFT_BIT, e
        jr      z, checkRight
        ld      a, LEFT_SPEED
        ld      hl, _LeftKnight0
        ld      (playerSprite), hl
        jr      updateXSpeedDone
checkRight:
        bit     RIGHT_BIT, e
        jr      z, noXMovement
        ld      a, RIGHT_SPEED
        ld      hl, _RightKnight0
        ld      (playerSprite), hl
        jr      updateXSpeedDone
noXMovement:
        xor     a
updateXSpeedDone:
        ld      (_xSpeed), a

        ;
        ; Update the jump status
        ;
        ld      hl, (jumpFall)          ; Falling and jumping flags
        ld      a, l                    ; must be zero before
        or      h                       ; a jump can be started
        jr      nz, cantJump            ; If nz, falling or jumping are non-zero

        bit     JUMP_BIT, e
        jr      z, cantJump


        ld      a, JUMP_SPEED
        ld      (_ySpeed), a

        ld      a, (eggCount)           ; Get egg count
        and     a                       ; Update the flags
        ld      a, JUMP_HEIGHT          ; Single jump height
        ld      b, AYFX_JUMP
        jr      z, smallJump            ; eggCount is zero

        add     a                       ; Double jump height
        inc     b                       ; Next jump sound index
smallJump:
        ld      (_jumping), a           ; Save jump distance
        rrca                            ; Divide by 2 for direction change. Only works if bit 0 is 0
        ld      (jumpMidpoint), a       ; Save for compare below
        ld      a, b
        call    wyz_play_sound
cantJump:

        ld      a, (_jumping)
        or      a
        jr      z, notJumping
jumpMidpoint    equ $+1
        cp      -1                      ; Compare value will be different if player has collected eggs
        jr      nz, notMidpoint
        ex      af, af'                 ; Save the jump counter
        ld      a, -JUMP_SPEED          ; Change jump direction, now going down.
        ld      (_ySpeed), a
        ex      af, af'                 ; Restore jump counter
notMidpoint:
        dec     a
        ld      (_jumping), a
notJumping:

		; ######################################
		;
		; Check if player is colliding with platforms
		; in the Y direction.
		;
		; ######################################
        call    checkYCol

		; ######################################
		;
		; Check if player is colliding with platforms
		; in the Y direction.
		;
		; ######################################
        ld      a, (_xSpeed)            ; If xSpeed != 0 player is moving
        or      a                       ; left or right.
        call    nz, checkXCol           ; Check for a collision.

		; ######################################
        ;
        ; Check for collisions with coins, eggs,
        ; hearts, and spiders, etc.
        ;
		; ######################################
        ld      hl, (currentCoinTable)
        ld      de, coinCollision
        call    checkItemCollision
        ld      hl, (currentEggTable)
        ld      de, eggCollision
        call    checkItemCollision
        ld      hl, (currentHeartTable)
        ld      de, heartCollision
        call    checkItemCollision
        ld      hl, (currentSpiderTable)
        ld      de, spiderCollision
        call    checkItemCollision

		; ######################################
		;
		; Rotate any visible coins.
		;
		; ######################################
        ld      hl, coinRotate
        dec     (hl)
        jp      p, noAnimate
        ld      (hl), ROTATE_COUNT      ; Reset rotate counter
        call    _animateCoins
noAnimate:

		; ######################################
		;
		; Redraw any moving items.
		;
		; ######################################
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _copyScreen

        ld      bc, (_xPos)
        call    _displaySprite

        ld      a, (ticks)
        rrca
        jr      c, skipOddFrame

		; ######################################
		;
		; The below code is only executed on even frame numbers
		;
		; ######################################
        call    updateSpiderPos

        ld      a, ID_SPIDER
        ld      hl, (currentSpiderTable)
        call    displayItems_pixel
        ;
        ; Flicker any lanterns on the screen
        ;
        ld      hl, _lanternList
        call    _lanternFlicker

skipOddFrame:
        ;
        ; See if the egg count needs to be decremented
        ;
        call    decrementEggs

        jp      gameLoop

gameOver:
        ld      sp, -1

        ld      bc, 0x0b0a
        ld      hl, gameOverMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        call    printAttr

        delay   200

        ret

_setCurrentTileMap:
        ld      a, (_tileMapY)
        ld      hl, TILEMAP_WIDTH*LEVEL_HEIGHT
        call    _mul_hla

        ex      de, hl

        ld      a, (_tileMapX)
        ld      hl, SCREEN_WIDTH
        call    _mul_hla

        add     hl, de

        ld      de, _levels
        add     hl, de

        ld      (_currentTileMap), hl

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

        ex      de, hl                  ; Save hl in de
        ld      hl, 0
        or      a                       ; If multiplying by 0, result is zero
        jr      z, mulDone

        ld      b, 8
nextMul:
        add     hl, hl
        rlca
        jr      nc, noAdd
        add     hl, de
noAdd:
        djnz    nextMul

mulDone:
        pop     de
        pop     bc
        ret

        section BSS_2
coinRotate:
        ds      1
_currentTileMap:
        ds      2
_tileMapX:
        ds      1
_tileMapY:
        ds      1
xyPos:
_xPos:
        ds      1
_yPos:
        ds      1
_xSpeed:
        ds      1
_ySpeed:
        ds      1
jumpFall:                               ; Access jumping and falling as a single word
_jumping:
        ds      1
_falling:
        ds      1
startSprite:
        ds      2
xyStartPos:                             ; Position where player entered the level
        ds      2
_spriteBuffer:
        ds      48

        section DATA_2
currentBank:
        db      MEM_BANK_ROM

        section RODATA_2
readyMsg:
        db      "Ready?", 0x00
gameOverMsg:
        db      " Game Over! ", 0x80, " ", 0x00
