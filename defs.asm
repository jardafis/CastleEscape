        module  defs

        ;
        ; Bit numbers for user keys
        ;
        defc    FIRE                    = 4
        defc    UP                      = 3
        defc    DOWN                    = 2
        defc    LEFT                    = 1
        defc    RIGHT                   = 0

        ;
        ; Screen addresses
        ;
        defc    SCREEN_START            = 0x4000
        defc    SCREEN_LENGTH           = 0x1800
        defc    SCREEN_END              = (SCREEN_START + SCREEN_LENGTH)
        defc    SCREEN_ATTR_START       = (SCREEN_START + SCREEN_LENGTH)
        defc    SCREEN_ATTR_LENGTH      = 0x300
        defc    SCREEN_ATTR_END         = (SCREEN_ATTR_START + SCREEN_ATTR_LENGTH)

        ;
        ; Screen attribute definitions
        ;
        defc    INK_BLACK               = 0x00
        defc    INK_BLUE                = 0x01
        defc    INK_RED                 = 0x02
        defc    INK_MAGENTA             = 0x03
        defc    INK_GREEN               = 0x04
        defc    INK_CYAN                = 0x05
        defc    INK_YELLOW              = 0x06
        defc    INK_WHITE               = 0x07

        defc    PAPER_BLACK             = 0x00
        defc    PAPER_BLUE              = 0x08
        defc    PAPER_RED               = 0x10
        defc    PAPER_MAGENTA           = 0x18
        defc    PAPER_GREEN             = 0x20
        defc    PAPER_CYAN              = 0x28
        defc    PAPER_YELLOW            = 0x30
        defc    PAPER_WHITE             = 0x38

        defc    BRIGHT                  = 0x40
        defc    FLASH                   = 0x80

        ;
        ; Address of the ZX Spectrum font in ROM
        ;
        defc    ROM_FONT                = 0x3d00

        ;
        ; I/O Ports
        ;
        defc    IO_BORDER               = 0xfe
        defc    IO_BEEPER               = 0xfe
        defc    IO_BANK                 = 0x7ffd

        ;
        ; Macros for use with asmpp.pl
        ;

        ;
        ; Multiply hl by times where times is 2, 4, 8, 16, 32, 64
        ;
hlx     macro   times
        IF times >=2
            add     hl,hl
        ENDIF
        IF times >= 4
            add     hl,hl
        ENDIF
        IF times >= 8
            add     hl,hl
        ENDIF
        IF times >= 16
            add     hl,hl
        ENDIF
        IF times >= 32
            add     hl,hl
        ENDIF
        IF times >= 64
            add     hl,hl
        ENDIF
    endm

entry   macro
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        ld      ix,12                   ; the 6 pushes above plus return address
        add     ix,sp
        endm

exit    macro
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        endm

        ;
        ; Push af-hl onto the stack
        ;
pushall macro
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        push    iy
        endm

        ;
        ; Pop hl-af off the stack
        ;
popall macro
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        endm

