        public  detectKempston
        public  kjPresent
        public  readKempston

        #include    "defs.inc"

        section CODE_2
        ;
        ;	Input:
        ;		None
        ;
        ;	Output:
        ;		Z - No Kempston present
        ;		NZ - Kempston present
detectKempston:
        halt
        in      a, (IO_KEMPSTON)
        inc     a
        ld      (kjPresent), a
        ret

        ;
        ; 	Input:
        ;		e - Current direction bits
        ;
        ;	Output:
        ;		e - Updated direction bits
        ;
readKempston:
        in      a, (IO_KEMPSTON)
        and     JUMP|UP|DOWN|LEFT|RIGHT
        or      e
        ld      e, a
        ret

        section BSS_2
kjPresent:
        ds      1
