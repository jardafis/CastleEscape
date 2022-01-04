        public  _levels
        public  _tileAttr

        section RODATA_0
_levels:
        #include    "levels.inc"
IF  !_ZXN
        section RODATA_5
ELSE
        section RODATA_2
ENDIF
_tileAttr:
        binary  "attrib.dat"
