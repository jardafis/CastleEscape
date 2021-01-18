		public	eggTables
		public	eggs
		public	currentEggTable

        include "defs.asm"

		section	code_user

        section bss_user
.currentEggTable	dw		0

eggTables:
		ds		MAX_LEVEL_X * MAX_LEVEL_Y * 2

eggs:
		ds		SIZEOF_item * 8 * MAX_LEVEL_X * MAX_LEVEL_Y
