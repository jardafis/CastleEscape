;       Exported routines
        public  wyz_play_frame
        public  wyz_play_song
        public  wyz_play_fx
        public  wyz_play_sound
        public  wyz_player_init
        public  wyz_player_stop

        section CODE_5
        #include    "wyzproplay47c_common.inc"

ROUT:   LD      A, (PSG_REG+13)
        AND     A
        JR      Z, NO_BACKUP_ENVOLVENTE
        LD      (ENVOLVENTE_BACK), A
        XOR     A
NO_BACKUP_ENVOLVENTE:
        LD      HL, PSG_REG_SEC
        LD      DE, $FFBF
        LD      BC, $FFFD
LOUT:   OUT     (C), A
        LD      B, E
        OUTI
        LD      B, D
        INC     A
        CP      13
        JR      NZ, LOUT
        OUT     (C), A
        LD      A, (HL)
        AND     A
        RET     Z
        LD      B, E
        OUTI
        XOR     A
        LD      (PSG_REG_SEC+13), A
        LD      (PSG_REG+13), A
        RET

        section RODATA_2
        ;
        ; Song table setup
        ;
        #include    "wyzsongtable.inc"

        section BSS_5
        ;
        ; RAM variables
        ;
        #include    "wyzproplay_ram.inc"
