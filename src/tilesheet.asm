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
        db      0xe3, 0x02, 0x03, 0x14
        db      0x16, 0x1f, 0xa0, 0xb4
        db      0xb6, 0xe0, 0xe7, 0xfc
        db      0xff, 0x00, 0x00, 0x00
tile_palette_end:
ENDIF
