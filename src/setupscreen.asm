        extern  _cls
        extern  currentCoinTable
        extern  _coinTables
        extern  setCurrentItemTable
        extern  currentEggTable
        extern  eggTables
        extern  currentHeartTable
        extern  heartTables
        extern  _setCurrentTileMap
        extern  _currentTileMap
        extern  displayTileMap
        extern  displayItems
        extern  display2BCD
        extern  display4BCD
        extern  heartCount
        extern  _scrollReset
        extern  displayBanner
        extern  spiderTables
        extern  currentSpiderTable
        extern  xyPos
        extern  xyStartPos
        extern  displayEggCount
        extern  playerSprite
        extern  startSprite
        extern  score

        public  _setupScreen

        include "defs.inc"

        section CODE_5

        ;
        ; Display the current level and any uncollected items.
        ;
_setupScreen:
        pushall

        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls

        ;
        ; Set the item tables for this level
        ;
        ld      hl, currentCoinTable
        ld      de, _coinTables
        call    setCurrentItemTable

        ld      hl, currentEggTable
        ld      de, eggTables
        call    setCurrentItemTable

        ld      hl, currentHeartTable
        ld      de, heartTables
        call    setCurrentItemTable

        ld      hl, currentSpiderTable
        ld      de, spiderTables
        call    setCurrentItemTable

        call    _setCurrentTileMap

        ld      hl, (_currentTileMap)
        call    displayTileMap

        call    displayBanner

        ld      a, ID_COIN
        ld      hl, (currentCoinTable)
        call    displayItems

        ld      a, ID_EGG
        ld      hl, (currentEggTable)
        call    displayItems

        ld      a, ID_HEART
        ld      hl, (currentHeartTable)
        call    displayItems

        call    displayEggCount

        ld      bc, 0x011d              ; y,x screen location
        ld      hl, heartCount          ; Point to 10's/1's
        call    display2BCD

        ld      bc, 0x0103              ; Y/X screen location
        ld      hl, score
        call    display4BCD

        call    _scrollReset

		; Save the location (and direction) where the player entered
		; the level. This is used as the starting
		; location when they die.
        ld      hl, (xyPos)
        ld      (xyStartPos), hl
        ld      hl, (playerSprite)
        ld      (startSprite), hl

        popall
        ret
