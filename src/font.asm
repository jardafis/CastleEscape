        public  _font_8x8_cpc_system

IF  !_ZXN
        section RODATA_5
ELSE
        section RODATA_2
ENDIF
_font_8x8_cpc_system:
        binary  "font_8x8_cpc_system.dat"
        ; Sad face ASCII 0x80 (128)
        defb    60
        defb    66
        defb    165
        defb    129
        defb    153
        defb    165
        defb    66
        defb    60

