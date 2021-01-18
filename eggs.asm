		extern	_xPos
		extern	_yPos
		extern	_addScore
		extern	_displayScore
		extern	clearAttr
		extern	clearChar

		public	eggTables
		public	eggs
		public	currentEggTable
		public	eggCollision

        include "defs.asm"

		defc	EGG_HEIGHT		= 0x07
		defc	EGG_WIDTH		= 0x08

		section	code_user

		;
		;
		;
eggCollision:
		ret


        section bss_user
.currentEggTable	dw		0

eggTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

eggs:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
