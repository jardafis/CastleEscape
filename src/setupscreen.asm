        extern  _cls
        extern  _coinTables
        extern  _currentTileMap
        extern  _scrollReset
        extern  _setCurrentTileMap
        extern  currentCoinTable
        extern  currentEggTable
        extern  currentHeartTable
        extern  currentSpiderTable
        extern  display2BCD
        extern  display4BCD
        extern  displayBanner
        extern  displayEggCount
        extern  displayItems
        extern  displayTileMap
        extern  eggTables
        extern  heartCount
        extern  heartTables
        extern  playerSprite
        extern  score
        extern  setCurrentItemTable
        extern  spiderTables
        extern  startSprite
        extern  xyPos
        extern  xyStartPos

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
