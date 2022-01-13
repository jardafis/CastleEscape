        extern  _font_8x8_cpc_system
        extern  currentBank
        extern  bankedCall
        extern  banked_call

		;
		; ZX Spectrum Next Definitions
		;
        defc    TILEMAP_START=0x5b00
        defc    TILEMAP_SIZE=0x500
        defc    TILEMAP_DEF_START=TILEMAP_START+TILEMAP_SIZE
        defc    ZXN_TILEMAP_WIDTH=40

        defc    IO_TileMapBaseAdrr=0x6E
        defc    IO_TileMapDefBaseAddr=0x6F
        defc    IO_TileMapContr=0x6B
        defc    IO_TileMapAttr=0x6C
        defc    IO_TileMapTransparency=0x4C
        defc    IO_TileMapPaletteContr=0x43
        defc    IO_PaletteIndex=0x40
        defc    IO_PaletteValue=0x41
        defc    IO_ULAControl=0x68
        defc    IO_TileMapOffSetXMSB=0x2F
        defc    IO_TileMapOffSetXLSB=0x30
        defc    IO_TileMapOffsetY=0x31
        defc    IO_TileMapClipWindow=0x1B
        defc    IO_SpriteAndLayers=0x15
        defc    IO_SpritePattern=0x5b
        defc    IO_SpriteNumber=0x34
        defc    IO_SpriteAttrib0=0x35
        defc    IO_SpriteAttrib1=0x36
        defc    IO_SpriteAttrib2=0x37
        defc    IO_SpriteAttrib3=0x38
        defc    IO_SpriteAttrib4=0x39
        defc    IO_TurboMode=0x07

        defc    SPRITE_ID_TOMBSTONE=5
        defc    SPRITE_ID_JUMP=4
        defc    SPRITE_ID_SPIDER_UP=6
        defc    SPRITE_ID_SPIDER_DOWN=10
        defc    SPRITE_ID_LANTERN=12

        defvars 0
        {
            spriteIndex ds.b 1
            attrib0     ds.b 1
            attrib1     ds.b 1
            attrib2     ds.b 1
            attrib3     ds.b 1
            attrib4     ds.b 1
            frameCount  ds.b 1
            currentFrameCount   ds.b 1
            startPtn    ds.b 1
            endPtn      ds.b 1
            currentPtn  ds.b 1
            SIZEOF_sprite
        }

        ;
        ; Points
        ;
        defc    COIN_POINTS=0x05

        ;
        ; WYZTracker Songs
        ;
        defc    TITLE_MUSIC=0
        defc    MAIN_MENU_MUSIC=1
        defc    DEATH_MARCH=2
        ;
        ; WYZTracker AYFX Indexes
        ;
        defc    AYFX_JUMP=0
        defc    AYFX_BIG_JUMP=1
        defc    AYFX_COLLECT_COIN=2
        defc    AYFX_COLLECT_EGG=3
        defc    AYFX_COLLECT_HEART=4
        defc    AYFX_FALLING=5
        defc    AYFX_DIE=6

        ;
        ; Game Configuration
        ;
        defc    START_X=48
        defc    START_Y=120
        defc    START_LIVES=0x03
        defc    ROTATE_COUNT=6
        DEFINE  ATTRIB_EDIT
;		DEFINE	TIMING_BORDER
        DEFINE  SOUND
;        DEFINE  CHEAT

        defvars 0
        {
            itemFlags   ds.b 1
            itemX       ds.b 1
            itemY       ds.b 1
            itemFrame   ds.b 1
            SIZEOF_item
        }

        defc    SIZEOF_int=0x02
        defc    SIZEOF_ptr=0x02
        defc    SIZEOF_byte=0x01


        ;
        ; Max items per level
        ;
        defc    MAX_LANTERNS=8
        defc    MAX_HEARTS=8
        defc    MAX_EGGS=8
        defc    MAX_COINS=8
        defc    MAX_SPIDERS=8

        ;
        ; Tilemap definitions
        ;
        defc    MAX_LEVEL_X=0x04
        defc    MAX_LEVEL_Y=0x06

        defc    TILEMAP_WIDTH=0x20*MAX_LEVEL_X
        defc    LEVEL_HEIGHT=21

        ;
        ; Non-printable keys
        ;
        defc    SHIFT=0x01
        defc    SYM=0x02

        ;
        ; Values numbers for control keys
        ;
        defc    JUMP=0x10
        defc    UP=0x08
        defc    DOWN=0x04
        defc    LEFT=0x02
        defc    RIGHT=0x01
        defc    JUMP_BIT=4
        defc    UP_BIT=3
        defc    DOWN_BIT=2
        defc    LEFT_BIT=1
        defc    RIGHT_BIT=0

        defc    JUMP_HEIGHT=24
        defc    LEFT_SPEED=-1
        defc    RIGHT_SPEED=1
        defc    JUMP_SPEED=-2
        defc    DOWN_SPEED=1
        defc    UP_SPEED=-1

        defc    PLAYER_WIDTH=16
        defc    PLAYER_HEIGHT=16
        defc    MAX_X_POS=256
        defc    MAX_Y_POS=192

        ;
        ; Sprite ID's
        ;
        defc    TILE_SHEET_WIDTH=16
        defc    TILE_SHEET_HEIGHT=16

        defc    ID_LANTERN=3
        defc    ID_BLANK=11
        defc    ID_COIN=6*TILE_SHEET_WIDTH
        defc    ID_EGG=5*TILE_SHEET_WIDTH+4
        defc    ID_EGG0=5*TILE_SHEET_WIDTH
        defc    ID_HEART=2*TILE_SHEET_WIDTH+10
        defc    ID_SPIDER=4*TILE_SHEET_WIDTH+3
        defc    ID_PLATFORM=11*TILE_SHEET_WIDTH+9


        ;
        ; Screen addresses
        ;
        defc    SCREEN1_START=0xc000
        defc    SCREEN_START=0x4000
        defc    SCREEN_LENGTH=0x1800
        defc    SCREEN_END=(SCREEN_START+SCREEN_LENGTH)
        defc    SCREEN_ATTR_START=(SCREEN_START+SCREEN_LENGTH)
        defc    SCREEN1_ATTR_START=(SCREEN1_START+SCREEN_LENGTH)
        defc    SCREEN_ATTR_LENGTH=0x300
        defc    SCREEN_ATTR_END=(SCREEN_ATTR_START+SCREEN_ATTR_LENGTH)
        defc    SCREEN_WIDTH=0x20
        defc    SCREEN_HEIGHT=0x18

        ;
        ; Screen attribute definitions
        ;
        defc    INK_BLACK=0x00
        defc    INK_BLUE=0x01
        defc    INK_RED=0x02
        defc    INK_MAGENTA=0x03
        defc    INK_GREEN=0x04
        defc    INK_CYAN=0x05
        defc    INK_YELLOW=0x06
        defc    INK_WHITE=0x07

        defc    PAPER_BLACK=0x00
        defc    PAPER_BLUE=0x08
        defc    PAPER_RED=0x10
        defc    PAPER_MAGENTA=0x18
        defc    PAPER_GREEN=0x20
        defc    PAPER_CYAN=0x28
        defc    PAPER_YELLOW=0x30
        defc    PAPER_WHITE=0x38

        defc    BRIGHT=0x40
        defc    FLASH=0x80

        ;
        ; Address of the font. If 0x3d00 is used this constant points
        ; to the font in the Spectrum ROM.
        ;
        defc    FONT=_font_8x8_cpc_system

        ;
        ; I/O Ports
        ;
        defc    IO_BORDER=0xfe
        defc    IO_BEEPER=0xfe
        defc    IO_BANK=0x7ffd
        defc    IO_KEMPSTON=0x1f
        defc    MIC_OUTPUT=0x08

        ;
        ; OpCodes
        ;
        defc    JP_OPCODE=0xc3

        ;
        ; Macros for use with asmpp.pl
        ;

        defc    MEM_BANK_ROM=0x10
        ;
        ; Bank select
        ;
bank    MACRO   num
        push    af
        push    bc
        ld      bc, IO_BANK
        ld      a, (currentBank)
        and     %11111000
        or      num
        ld      (currentBank), a
        out     (c), a
        pop     bc
        pop     af
        ENDM

screen  MACRO   num
        extern  currentBank
        push    af
        push    bc
        ld      bc, IO_BANK
        ld      a, (currentBank)
        and     %11110111
        or      num<<3
        ld      (currentBank), a
        halt
        out     (c), a
        pop     bc
        pop     af
        ENDM

        ;
        ; Multiply hl by times where times is 2, 4, 8, 16, 32, 64
        ;
hlx     MACRO   times
IF  times>=2
        add     hl, hl
ENDIF
IF  times>=4
        add     hl, hl
ENDIF
IF  times>=8
        add     hl, hl
ENDIF
IF  times>=16
        add     hl, hl
ENDIF
IF  times>=32
        add     hl, hl
ENDIF
IF  times>=64
        add     hl, hl
ENDIF
IF  times>=128
        add     hl, hl
ENDIF
        ENDM

ax      MACRO   times
IF  times>=2
        add     a
ENDIF
IF  times>=4
        add     a
ENDIF
IF  times>=8
        add     a
ENDIF
IF  times>=16
        add     a
ENDIF
IF  times>=32
        add     a
ENDIF
IF  times>=64
        add     a
ENDIF
IF  times>=128
        add     a
ENDIF
        ENDM

entry   MACRO
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        ld      ix, 12                  ; the 5 pushes above plus return address
        add     ix, sp
        ENDM

exit    MACRO
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        ENDM

        ;
        ; Push af-hl onto the stack
        ;
pushall MACRO
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        push    iy
        ENDM

        ;
        ; Pop hl-af off the stack
        ;
popall  MACRO
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        ENDM

        ;
        ; Add 'a' to 'hl'
        ;
addhl   MACRO val
IF  _ZXN
        add     hl, val
ELSE
        ld      a, val
        add     l
        ld      l, a
        adc     h
        sub     l
        ld      h, a
endif
        ENDM

        ;
        ; Add 'a' to 'de'
        ;
addde   MACRO val
IF  _ZXN
        add     de, val
ELSE
        ld      a, val
        add     e
        ld      e, a
        adc     d
        sub     e
        ld      d, a
ENDIF
        ENDM

        ;
        ; Add 'a' to 'bc'
        ;
addbc   MACRO val
IF  _ZXN
        add     bc, val
ELSE
        ld      a, val
        add     c
        ld      c, a
        adc     b
        sub     c
        ld      b, a
ENDIF
        ENDM

mod     MACRO   val
        LOCAL   modLoop
modLoop:
        sub     a, val
        jp      p, modLoop
        add     a, val
        ENDM

        ;
        ; Calculate screen row address
        ;
calculateRow    MACRO   row
        extern  _screenTab
        ld      l, row                  ; Get the screen y pixel position
        ld      h, 0
        add     hl, hl                  ; Multiply it by 2
        ld      sp, _screenTab          ; and add it to the screen
        add     hl, sp                  ; table address.
        ld      sp, hl                  ; Save the result in sp.
        ENDM

        ;
        ; Delay in increments of 1/50th of a second.
        ;
        ; Interrupts must be enabled!
        ;
delay   MACRO   val
        LOCAL   delayLoop
        push    bc
        ld      b, val
delayLoop:
        halt
        djnz    delayLoop
        pop     bc
        ENDM

assert  MACRO
        di
        halt
        ENDM

border  MACRO   color
        ld      a, color
        or      MIC_OUTPUT              ; Disable the MIC output
        out     (IO_BORDER), a
        ENDM

        ;
        ; Banked call to function
        ;
bcall   MACRO   function
        call    banked_call
        dw      function
        dw      function>>16|MEM_BANK_ROM
        ENDM

        ;
        ; Convert Y/X pixel coords to character coords.
        ;
        ; Entry:
        ;   Y - Y pixel location
        ;   X - X pixel location
        ;
        ; Exit:
        ;   Y - Y character location
        ;   X - X character location
        ;
        ; Notes:
        ;   On exit 'a' is the X character location
        ;
pixelToChar MACRO   Y, X
        ld      a, Y                    ; Y char position
        rrca                            ; Divide by 8
        rrca
        rrca
        and     %00011111               ; Remove garbage
        ld      Y, a

        ld      a, X                    ; X char position
        rrca                            ; Divide by 8
        rrca
        rrca
        and     %00011111               ; Remove garbage
        ld      X, a
        ENDM
