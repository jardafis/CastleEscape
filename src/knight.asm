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
        #include    "sprite/sprites.inc"
spriteEnd:
spritePalette:
        db      0x00, 0x02, 0xa0, 0xa2, 0x14, 0x16, 0xb4, 0xb6, 0x00, 0x03, 0xe0, 0xe7, 0x1c, 0x1f, 0xfc, 0xff
spritePaletteEnd:
ENDIF
