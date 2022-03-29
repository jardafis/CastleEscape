IF  !_ZXN
        public  _LeftKnight0
        public  _RightKnight0
        public  RightJumpKnight0
        public  RightFallKnight0
        public  LeftJumpKnight0
        public  LeftFallKnight0

        section RODATA_2

_RightKnight0:
        binary  "sprite/RightKnight.raw"
_LeftKnight0:
        binary  "sprite/LeftKnight.raw"
RightJumpKnight0:
        binary  "sprite/RightJumpKnight.raw"
RightFallKnight0:
        binary  "sprite/RightFallKnight.raw"
LeftJumpKnight0:
        binary  "sprite/LeftJumpKnight.raw"
LeftFallKnight0:
        binary  "sprite/LeftFallKnight.raw"
ELSE
        section RODATA_4

        public  spriteStart
        public  spriteEnd
        public  spritePalette
        public  spritePaletteEnd
spriteStart:
        binary  "sprite/ZXN_Sprites.spr"
spriteEnd:
spritePalette:
        binary  "sprite/ZXN_Sprites.nxp"
spritePaletteEnd:
ENDIF
