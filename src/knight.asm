IF  !_ZXN
        public  _LeftKnight0
        public  _RightKnight0
        public  RightJumpKnight0
        public  LeftJumpKnight0

        section RODATA_2

_RightKnight0:
        #include    "sprite/RightKnight.inc"
_LeftKnight0:
        #include    "sprite/LeftKnight.inc"
RightJumpKnight0:
        #include    "sprite/RightJumpKnight.inc"
LeftJumpKnight0:
        #include    "sprite/LeftJumpKnight.inc"
ELSE
        section RODATA_4

        public  spriteStart
        public  spriteEnd
        public  spritePalette
        public  spritePaletteEnd
spriteStart:
        binary  "sprite/sprites.spr"
spriteEnd:
spritePalette:
        binary  "sprite/sprites.pal"
spritePaletteEnd:
ENDIF
