cmake_minimum_required(VERSION 3.16)

# Toolchain configuration
set(CMAKE_C_COMPILER zcc)
set(CMAKE_ASM_COMPILER z88dk-z80asm)

project(CastleEscape C ASM)

set(ZXSTLC ${PROJECT_SOURCE_DIR}/tools/zxstlc)

if(NOT DEFINED TARGET)
    set(Z88DK_TARGET +zx)
else()
    set(Z88DK_TARGET ${TARGET})
endif()

if(${Z88DK_TARGET} STREQUAL +zx)
    set(CMAKE_ASM_FLAGS "-mz80")
    set(EMU "fuse")
    message(STATUS "Building for ZX Spectrum 128K")
elseif(${Z88DK_TARGET} STREQUAL +zxn)
    set(CMAKE_ASM_FLAGS "-mz80n -D_ZXN=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_ZXN=1")
    set(EMU $ENV{HOME}/ZEsarUX-10.0/zesarux --machine TBBlue --configfile .zesaruxrc --tbblue-fast-boot-mode  --nosplash --nowelcomemessage --quickexit)
    message(STATUS "Building for ZX Spectrum Next")
endif()


set(Z88DK_TARGET +zx)
set(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} -O2 \
    --codeseg=CODE_4 \
    --constseg=RODATA_4 \
    --dataseg=DATA_4 \
    --bssseg=BSS_4 \
    -clib=new"
)
set(CMAKE_EXE_LINKER_FLAGS "-crt0 ${PROJECT_SOURCE_DIR}/crt/crt.asm -m")

set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> ${Z88DK_TARGET} <FLAGS> -c <DEFINES> <INCLUDES> -o<OBJECT> <SOURCE>")
set(CMAKE_ASM_COMPILE_OBJECT "<CMAKE_ASM_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -o<OBJECT> <SOURCE>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> ${Z88DK_TARGET} <LINK_FLAGS> <OBJECTS> -o${PROJECT_NAME}")

include_directories(${PROJECT_SOURCE_DIR})

set(SOURCES
    attribedit.c
    bankedcall.asm
    banner.asm
    cls.asm
    coins.asm
    definekeys.asm
    die.asm
    displaybcd.asm
    displayhex.asm
    displaytilemap.asm
    dzx0_standard.asm
    eggs.asm
    gamemain.asm
    heapcheck.asm
    hearts.asm
    isr.asm
    items.asm
    kempston.asm
    keyboardscan.asm
    knight.asm
    lantern.asm
    levels.asm
    mainmenu.asm
    menuscreen.asm
    playercollision.asm
    print.asm
    random.asm
    screentab.asm
    scrollmessage.asm
    setupscreen.asm
    spiders.asm
    sprite.asm
    sprite_zxn.asm
    tiles.asm
    tiles_zxn.asm
    tilesheet.asm
    title.asm
    wyzproplay_zx.asm
    zxn.asm
    )

set_property(SOURCE banner.asm APPEND PROPERTY OBJECT_DEPENDS ${PROJECT_SOURCE_DIR}/banner.nxm)
set_property(SOURCE print.asm APPEND PROPERTY OBJECT_DEPENDS ${PROJECT_SOURCE_DIR}/Torment.ch8)
set_property(SOURCE menuscreen.asm APPEND PROPERTY OBJECT_DEPENDS ${PROJECT_SOURCE_DIR}/mainmenu.scr.zx0)

set_property(SOURCE levels.asm
    APPEND PROPERTY OBJECT_DEPENDS
    ${PROJECT_SOURCE_DIR}/attrib.dat
    ${PROJECT_SOURCE_DIR}/levels.nxm
    )

    set_property(SOURCE knight.asm
    APPEND PROPERTY OBJECT_DEPENDS
    ${PROJECT_SOURCE_DIR}/sprite/LeftFallKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/LeftJumpKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/LeftKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/RightFallKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/RightJumpKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/RightKnight.raw
    ${PROJECT_SOURCE_DIR}/sprite/ZXN_Sprites.spr
    ${PROJECT_SOURCE_DIR}/sprite/ZXN_Sprites.nxp
    )

set_property(SOURCE wyzproplay_zx.asm
    APPEND PROPERTY OBJECT_DEPENDS
    ${PROJECT_SOURCE_DIR}/music/gothic.mus
    ${PROJECT_SOURCE_DIR}/music/jinj_med.mus
    ${PROJECT_SOURCE_DIR}/music/death.wyz.mus
    )

set_property(SOURCE tilesheet.asm
    APPEND PROPERTY OBJECT_DEPENDS
    ${PROJECT_SOURCE_DIR}/sprite/ZXS_tilesheet.nxt
    ${PROJECT_SOURCE_DIR}/sprite/ZXN_tilesheet.nxt
    ${PROJECT_SOURCE_DIR}/sprite/ZXN_tilesheet.nxp
    )

add_executable(${PROJECT_NAME}_BANK_2.bin ${SOURCES})

set_target_properties(${PROJECT_NAME}_BANK_2.bin
    PROPERTIES
        ADDITIONAL_CLEAN_FILES "CastleEscape.map;${PROJECT_NAME}_BANK_0.bin;${PROJECT_NAME}_BANK_1.bin;${PROJECT_NAME}_BANK_2.bin;${PROJECT_NAME}_BANK_3.bin;${PROJECT_NAME}_BANK_4.bin;${PROJECT_NAME}_BANK_5.bin;${PROJECT_NAME}_BANK_6.bin;${PROJECT_NAME}_BANK_7.bin"
)

# Generate main binary consisting of banks 5, 2, and 0
add_custom_command(OUTPUT ${PROJECT_NAME}.bin
    COMMAND cp ${PROJECT_NAME}_BANK_5.bin ${PROJECT_NAME}.bin
    COMMAND dd if=/dev/null of=${PROJECT_NAME}.bin bs=1 count=1 seek=8K
    COMMAND cat ${PROJECT_NAME}_BANK_2.bin >> ${PROJECT_NAME}.bin
    COMMAND dd if=/dev/null of=${PROJECT_NAME}.bin bs=1 count=1 seek=24K
    COMMAND cat ${PROJECT_NAME}_BANK_0.bin >> ${PROJECT_NAME}.bin
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_BANK_2.bin
)

add_custom_command(OUTPUT ${PROJECT_SOURCE_DIR}/mainmenu.scr.zx0
    COMMAND z88dk-zx0 -f -q ${PROJECT_SOURCE_DIR}/mainmenu.scr
    DEPENDS ${PROJECT_SOURCE_DIR}/mainmenu.scr)

# Steps to generate the .tap file
add_custom_command(OUTPUT ${PROJECT_NAME}.tap
    COMMAND ${ZXSTLC} -t ${PROJECT_NAME}.bin 24576 `${PROJECT_SOURCE_DIR}/getMain.sh` -l ${PROJECT_SOURCE_DIR}/title.scr -n CastleEsc -4 ${PROJECT_NAME}_BANK_4.bin -e
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin ${PROJECT_SOURCE_DIR}/title.scr
)

# Steps to generate the .dsk file
add_custom_command(OUTPUT ${PROJECT_NAME}.dsk
    COMMAND ${ZXSTLC} -d ${PROJECT_NAME}.bin 24576 `${PROJECT_SOURCE_DIR}/getMain.sh` -l ${PROJECT_SOURCE_DIR}/title.scr -4 ${PROJECT_NAME}_BANK_4.bin -e
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin ${PROJECT_SOURCE_DIR}/title.scr
)

# Disassemble the main binary
add_custom_target(dis z88dk-dis -o 24576 -x ${PROJECT_NAME}.map ${PROJECT_NAME}.bin | less DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.bin)
# Run the tape image with fuse
add_custom_target(run ${EMU} ${PROJECT_NAME}.tap DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.tap)
# Run the disk image (+3) with fuse
add_custom_target(rundsk ${EMU} ${PROJECT_NAME}.dsk DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.dsk)
