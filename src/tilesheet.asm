        public  _tile0

        section RODATA_5

        ;
        ; Include the auto generated tile data
        ;
_tile0:
IF  !_ZXN
        #include    "sprite/tilesheet.inc"
ELSE
        binary  "sprite/tilesheet.nxt"
tiles_end:
        section RODATA_2
        public  tile_palette
        public  tile_palette_end

		; Palette format is  (B1 << 8) | RGB332
		; Therfore, the odd bytes are not used when setting up the palette.
tile_palette:
        binary  "sprite/tilesheet.nxp"
tile_palette_end:
ENDIF
