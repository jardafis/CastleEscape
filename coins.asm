		extern	_levels
		public	_initCoins


		include	"defs.asm"

		defc	MAX_LEVEL_X		= 0x02
		defc	MAX_LEVEL_Y		= 0x02
		defc	ID_COIN			= 74
		section	code_user
		;
		; Initialize the coin tables. This routine is called once
		; at the start of each game to initialize the coin tables.
		;
		; The routine scans each level from top right to bottom left
		; building up a table of coins for each level. These tables
		; are then used by the coin animation routines and the coin
		; collision routine.
		;
_initCoins:
		pushall

		ld		hl,-SIZEOF_vars
		add		hl,sp
		ld		ix,hl

		;
		; Initialize memory variables
		;
		ld		(ix+levelY), MAX_LEVEL_Y
		ld		(ix+coinCount), 0
		ld		hl,_levels
		ld		(currentLevel), hl

.levelYLoop
		ld		(ix+levelX), MAX_LEVEL_X
.levelXLoop
		ld		(ix+tileY), 0
		ld		c,SCREEN_HEIGHT
.tileYLoop
		ld		(ix+tileX), 0
		ld		b,SCREEN_WIDTH
.tileXLoop
		ld		a,(hl)					; Get tile ID
		inc		hl
		cmp		ID_COIN
		jr		nz,noCoin
		inc		(ix+coinCount)
.noCoin
		inc		(ix+tileX)
		djnz	tileXLoop


		ld		de,SCREEN_WIDTH * MAX_LEVEL_X - SCREEN_WIDTH
		add		hl,de

		inc		(ix+tileY)
		dec		c
		jr		nz,tileYLoop

		;
		; Move the current level pointer to the next level to the right
		;
		ld		hl,(currentLevel)
		ld		de,SCREEN_WIDTH
		add		hl,de
		ld		(currentLevel),hl

		;
		; Decrement X counter and loop if not zero
		;
		dec		(ix+levelX)
		jr		nz,levelXLoop

		;
		; Move the current level pointer to the next level down
		;
		ld		hl,(currentLevel)
		ld		de,-64
		add		hl,de
		ld		de,SCREEN_WIDTH * MAX_LEVEL_X * SCREEN_HEIGHT
		add		hl,de
		ld		(currentLevel),hl

		;
		; Decrement Y counter and loop if not zero
		;
		dec		(ix+levelY)
		jr		nz,levelYLoop

.done
		popall
		ret

		defvars 0	;
		{
			levelX			ds.b	1
			levelY			ds.b	1
			tileX			ds.b	1
			tileY			ds.b	1
			currentLevel	ds.w	1
			coinCount		ds.b	1
			SIZEOF_vars
		}
