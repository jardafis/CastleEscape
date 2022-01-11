        public  _tile0

        section RODATA_5

        ;
        ; Include the auto generated tile data
        ;
_tile0:
IF  !_ZXN
        #include    "sprite/tilesheet.inc"
ELSE
        #include    "sprite/tilesheet_zxn.inc"
tiles_end:
        section RODATA_2
        public  tile_palette
        public  tile_palette_end
tile_palette:
        db      0xe3, 0x02, 0xa0, 0xa2
        db      0x14, 0x16, 0xb4, 0xb6
        db      0x00, 0x03, 0xe0, 0xe7
        db      0x1c, 0x1f, 0xfc, 0xff
tile_palette_end:
ENDIF
