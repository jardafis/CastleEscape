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
