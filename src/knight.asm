IF  !_ZXN
        public  _LeftKnight0
        public  _RightKnight0
        public  RightJumpKnight0
        public  RightFallKnight0
        public  LeftJumpKnight0
        public  LeftFallKnight0

        section RODATA_2

_RightKnight0:
        #include    "sprite/RightKnight.inc"
_LeftKnight0:
        #include    "sprite/LeftKnight.inc"
RightJumpKnight0:
        #include    "sprite/RightJumpKnight.inc"
RightFallKnight0:
        #include    "sprite/RightFallKnight.inc"
LeftJumpKnight0:
        #include    "sprite/LeftJumpKnight.inc"
LeftFallKnight0:
        #include    "sprite/LeftFallKnight.inc"
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
