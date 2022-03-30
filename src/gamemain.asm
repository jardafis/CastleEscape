IF  !_ZXN
        extern  _LeftKnight0
        extern  _RightKnight0
        extern  RightJumpKnight0
        extern  LeftJumpKnight0
        extern  RightFallKnight0
        extern  LeftFallKnight0
ELSE
        extern  zxnInit
        extern  enableSprite
        extern  knightSprite
        extern  disableAllSprites
ENDIF
        extern  _animateCoins
        extern  _cls
        extern  _coinTables
        extern  _copyScreen
        extern  _displaySprite
        extern  _initItems
        extern  _lanternFlicker
        extern  _lanternList
        extern  _levels
        extern  _pasteScreen
        extern  _scroll
        extern  _scrollInit
        extern  _setupScreen
        extern  _updateDirection
        extern  checkItemCollision
        extern  checkXCol
        extern  checkYCol
        extern  coinCollision
        extern  currentCoinTable
        extern  currentEggTable
        extern  currentHeartTable
        extern  currentSpiderTable
        extern  decrementEggs
        extern  detectKempston
        extern  displayPixelItems
        extern  displaySpiders
        extern  eggCollision
        extern  eggCount
        extern  eggTables
        extern  heartCollision
        extern  heartCount
        extern  heartTables
        extern  initISR
        extern  kjScan
        extern  mainMenu
        extern  playerSprite
        extern  printAttr
        extern  readKempston
        extern  score
        extern  spiderCollision
        extern  spiderTables
        extern  titleScreen
        extern  updateSpiderPos
        extern  wyz_play_sound
        extern  wyz_player_init
        extern  __HEAP_2_head
        extern  __BANK_0_head
        extern  heapCheck
        extern  __STACK_tail
        extern  ticks

        public  _currentTileMap
        public  _falling
        public  _jumping
        public  _main
        public  _setCurrentTileMap
IF  !_ZXN
        public  _spriteBuffer
        public  lastDirection
ENDIF
        public  _tileMapX
        public  _tileMapY
        public  _xPos
        public  _xSpeed
        public  _yPos
        public  _ySpeed
        public  gameOver
        public  newGame
        public  score
        public  startSprite
        public  xyPos
        public  xyStartPos
        public  _bank2HeapEnd
        public  resetPlayer
        public  jumpFall

        #include    "defs.inc"

        section CODE_2
_main:
        ld      sp, __STACK_tail
        call    init

        bcall   titleScreen

        call    mainMenu

        assert

init:
        border  INK_BLACK

IF  _ZXN
        call    zxnInit
ENDIF
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
        border  0
        ld      (gameOver+1), sp

        ld      l, INK_BLACK|PAPER_BLACK
        call    _cls

        ld      bc, 0x0b0c
        ld      hl, readyMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        bcall   printAttr

        ;
        ; Ensure the tilemap data is paged in
        ;
        bank    _levels>>16

        ;
        ; Initialize the coin tables
        ;
        ; The goal is to reduce memory footprint.
        ; Since nothing else uses heap, just start
        ; from the beginning each time
        ld      de, __HEAP_2_head
        ld      hl, _coinTables
        ld      a, ID_COIN
        call    _initItems
        ;
        ; Initialize the egg tables
        ;
        ld      hl, eggTables
        ld      a, ID_EGG
        call    _initItems
        ;
        ; Initialize the hearts tables
        ;
        ld      hl, heartTables
        ld      a, ID_HEART
        call    _initItems
        ;
        ; Initialize the hearts tables
        ;
        ld      hl, spiderTables
        ld      a, ID_SPIDER
        call    _initItems

        ; Save the new end of heap pointer
        ld      (_bank2HeapEnd), de
        ld      hl, __BANK_0_head
        call    heapCheck

        ;
        ; Set the initial player sprite
        ;
IF  !_ZXN
        ld      hl, _RightKnight0
        ld      (playerSprite), hl
        xor     a
        ld      (lastDirection), a
ELSE
        xor     a
        ld      (playerSprite), a
        ld      ix, knightSprite
        call    enableSprite
ENDIF

        ;
        ; Starting X and Y player position
        ;
        ld      hl, START_Y<<8|START_X
        call    resetPlayer

        ;
        ; Set the current tilemap
        ;
        xor     a
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

IF  !_ZXN
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _copyScreen
ENDIF

        ;
        ; The game loop
        ;
        ; The game loop does the following basic operations.
        ; * Remove any moving items from the screen at their current position
        ; * Update user inputs
        ; * Update the position of any moving items
        ; * Re-draw any moving items at their new position
        ; * Non-critical stuff:
        ;   * Decrement egg count
        ;   * Scrolling message
        ;
        ; Note: Playing music in the ISR takes time away from
        ;       critical drawing functions.
gameLoop:
        ;
        ; Wait for refresh interrupt
        ;
        REPT    1
        halt
        ENDR
        ; ######################################
        ;
        ; Remove any moving items from the screen
        ;
        ; ######################################
IF  !_ZXN
        ;
        ; Re-draw the screen at the players current location
        ;
        ld      hl, _spriteBuffer
        call    _pasteScreen

        ;
        ; Remove spiders
        ;
        ld      a, ID_BLANK
        ld      hl, (currentSpiderTable)
        call    displayPixelItems
ENDIF

        ; ######################################
        ;
        ; Update user input
        ;
        ; ######################################
        call    _updateDirection

        ;
        ; Handle the keyboard input from the user
        ; 'e' contains the direction bits from
        ; the call to _updateDirection above.
        ;
IF  !_ZXN
        ld      a, e
        and     LEFT|RIGHT
        jr      z, dontSave
        ld      (lastDirection), a
dontSave:
ENDIF
        ;
        ; Update the X speed based on the user input
        ;
        bit     LEFT_BIT, e
        jr      z, checkRight
IF  _ZXN
        ld      a, 1
        ld      (playerSprite), a
ENDIF
        ld      a, LEFT_SPEED
        jr      updateXSpeedDone
checkRight:
        bit     RIGHT_BIT, e
        jr      z, noXMovement
IF  _ZXN
        xor     a
        ld      (playerSprite), a
ENDIF
        ld      a, RIGHT_SPEED
        jr      updateXSpeedDone
noXMovement:
        xor     a
updateXSpeedDone:
        ld      (_xSpeed), a

        ; Check if the jump key is pressed
        ; and try to start a jump
        bit     JUMP_BIT, e
        call    nz, startJump

        ; Skip the code that follows if not jumping
        ld      a, (_jumping)
        or      a
        jr      z, continueJumping

        ld      hl, jumpCnt
        dec     (hl)
        jp      p, continueJumping

        call    getJumpSequence
        jr      c, stillJumping
stopJumping:
        ; Stop jumping, zero y speed
        ld      (_jumping), a
stillJumping:
        ld      (_ySpeed), a
continueJumping:

IF  !_ZXN
        call    setPlayerSprite
ENDIF
        ; ######################################
        ;
        ; Check if player is colliding with platforms
        ; in the Y direction.
        ;
        ; ######################################
        call    checkYCol

        ld      a, (ticks)
        and     0x01
        jr      z, noXUpdate
        ; ######################################
        ;
        ; Check if player is colliding with platforms
        ; in the X direction.
        ;
        ; ######################################
        ld      a, (_xSpeed)            ; If xSpeed != 0 player is moving
        or      a                       ; left or right.
        call    nz, checkXCol           ; Check for a collision.
noXUpdate:

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
IF  !_ZXN
        ld      de, _spriteBuffer
        ld      bc, (_xPos)
        call    _copyScreen
ENDIF

        ld      bc, (_xPos)
        call    _displaySprite

        call    updateSpiderPos
        call    displaySpiders
        ;
        ; Flicker any lanterns on the screen
        ;
        ld      hl, _lanternList
        call    _lanternFlicker

        ;
        ; See if the egg count needs to be decremented
        ;
        call    decrementEggs

        ; ######################################
        ;
        ; Update the scrolling message
        ;
        ; ######################################
        call    _scroll

        jp      gameLoop

gameOver:
        ld      sp, -1

        ld      bc, 0x0b0a
        ld      hl, gameOverMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT
        bcall   printAttr

        delay   200

IF  _ZXN
        call    disableAllSprites
ENDIF
        ret

_setCurrentTileMap:
        ld      a, (_tileMapY)
        ld      hl, TILEMAP_WIDTH*LEVEL_HEIGHT
        mul_hla

        ex      de, hl

        ld      a, (_tileMapX)
        ld      hl, SCREEN_WIDTH
        mul_hla

        add     hl, de

        ld      de, _levels
        add     hl, de

        ld      (_currentTileMap), hl

        ret

startJump:
        ; Only start a jump if not currently jumping or falling
        ld      hl, (jumpFall)
        ld      a, h
        or      l
        ret     nz

        ; Set the jumping flag
        inc     l
        ld      (jumpFall), hl

        ; Big or short jump?
        ld      a, (eggCount)           ; Get egg count
        or      a

        ; Setup for small jump
        ld      hl, smallJump
        ld      c, AYFX_JUMP
        jr      z, small

        ; Big jump instead
        inc     c
        ld      hl, bigJump
small:
        call    getJumpSequence1
        ld      (_ySpeed), a


        push    de
        di
        ld      a, c
        ld      b, AYFX_CHANNEL+1
        call    wyz_play_sound
        ei
        pop     de
        ret

		;
		; Get the next jump sequence from the jump table
		;
		; Exit:
		;	a = jump speed
		;	cf = 1 next jump sequence
		;	cf = 0 end of jump sequence
		;
getJumpSequence:
        ; Get count & y speed from jump table
        ld      hl, (jumpPos)
getJumpSequence1:
        ld      a, (hl)                 ; Count
        or      a
        ret     z                       ; cf = 0
        inc     hl
        ld      (jumpCnt), a
        ld      a, (hl)                 ; Jump speed
        inc     hl
        ld      (jumpPos), hl
        scf                             ; cf = 1
        ret

        ;
        ; Initialize the X/Y speed variables
        ;
        ; Input:
        ;   h - Player Y pixel location
        ;   l - Player X pixel location
        ;
        ; Output:
        ;	a - Corrupted
        ;
resetPlayer:
        ld      (xyPos), hl
        xor     a
        ld      (_xSpeed), a
        ld      (_ySpeed), a
        ld      (_jumping), a
        ld      (_falling), a
        ret

IF  !_ZXN
		;
		; Set the sprite animation.
		;
		; Input:
		;	None.
		;
setPlayerSprite:
        ; Default to walking
        ld      hl, walkingTab

        ; Check for falling or jumping
        ; these states override walking
        ld      bc, (jumpFall)
        ld      a, b
        or      c
        call    nz, jumpingSprite

playerSpriteDone:
        ld      a, (lastDirection)
        and     0x02
        addhl   a

        ld      e, (hl)
        inc     hl
        ld      d, (hl)

        ld      (playerSprite), de
        ret

jumpingSprite:
        ld      hl, fallingTab
        ld      a, (_ySpeed)
        and     0x80
        ret     z

        ld      hl, jumpingTab
        ret

        section RODATA_2
walkingTab:
        dw      _RightKnight0, _LeftKnight0
jumpingTab:
        dw      RightJumpKnight0, LeftJumpKnight0
fallingTab:
        dw      RightFallKnight0, LeftFallKnight0
ENDIF

        section BSS_2
jumpCnt:
        ds      1
jumpPos:
        ds      2
score:                                  ; Score in BCD
        ds      2
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
IF  !_ZXN
_spriteBuffer:
        ds      3*PLAYER_HEIGHT
lastDirection:
        ds      1
ENDIF

        section DATA_2
_bank2HeapEnd:
        dw      __HEAP_2_head
currentBank:
        db      MEM_BANK_ROM

        section RODATA_4
readyMsg:
        db      "Ready?", 0x00
gameOverMsg:
        db      " Game Over! ", 0x80, " ", 0x00

        section RODATA_2
smallJump:
        db      0x0c, 0xfe              ; 12 frames up
        db      0x04, 0xff              ; 4 frames hover
        db      0x0b, 0x00              ; 12 frames down
        db      0x00                    ; End of jump
bigJump:
        db      0x18, 0xfe              ; 24 frames up
        db      0x08, 0xff              ; 8 frames hover
        db      0x17, 0x00              ; 24 frames down
        db      0x00                    ; End of jump
