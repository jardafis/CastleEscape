cmake_minimum_required(VERSION 3.16)

project(CastleEscape C ASM)
set(CMAKE_C_COMPILER zcc)
set(CMAKE_ASM_COMPILER z88dk-asmpp)
set(ZXSTLC ${PROJECT_SOURCE_DIR}/tools/zxstlc_linux)

set(CMAKE_C_FLAGS
    "+zx \
    -I${PROJECT_SOURCE_DIR} \
    -O2 \
    --codeseg=CODE_4 \
    --constseg=RODATA_4 \
    --dataseg=DATA_4 \
    --bssseg=BSS_4 \
    -clib=new"
)

set(CMAKE_ASM_FLAGS
    "-mz80\
    -I${PROJECT_SOURCE_DIR}"
)

set(LDFLAGS
    "+zx \
    -crt0 ${PROJECT_SOURCE_DIR}/crt/crt.asm \
    -m"
)

set(SOURCES
    attribedit.c
    bankedcall.asm
    banner.asm
    cls.asm
    coins.asm
    definekeys.asm
    die.asm
    displaybcd.asm
    displaytilemap.asm
    eggs.asm
    font.asm
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
    tiles.asm
    tilesheet.asm
    title.asm
    wyzproplay_zx.asm
    defs.inc
    )

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> ${LDFLAGS} <OBJECTS> -o ${PROJECT_NAME}")
add_executable(${PROJECT_NAME}_BANK_2.bin ${SOURCES})

set_target_properties(${PROJECT_NAME}_BANK_2.bin
    PROPERTIES
        ADDITIONAL_CLEAN_FILES "CastleEscape.map;${PROJECT_NAME}_BANK_0.bin;${PROJECT_NAME}_BANK_1.bin;${PROJECT_NAME}_BANK_2.bin;${PROJECT_NAME}_BANK_3.bin;${PROJECT_NAME}_BANK_4.bin;${PROJECT_NAME}_BANK_5.bin;${PROJECT_NAME}_BANK_6.bin;${PROJECT_NAME}_BANK_7.bin"
)

# Steps to generate the .tap and .dsk files
add_custom_command(TARGET ${PROJECT_NAME}_BANK_2.bin POST_BUILD
    BYPRODUCTS ${PROJECT_NAME}.tap ${PROJECT_NAME}.dsk ${PROJECT_NAME}.bin
    COMMAND cp ${PROJECT_NAME}_BANK_5.bin ${PROJECT_NAME}.bin
    COMMAND dd if=/dev/null of=${PROJECT_NAME}.bin bs=1 count=1 seek=8192
    COMMAND cat ${PROJECT_NAME}_BANK_2.bin >> ${PROJECT_NAME}.bin
    COMMAND ${ZXSTLC} -b ${PROJECT_NAME}.bin 24576 24576 -l ${PROJECT_SOURCE_DIR}/title.scr -n CastleEsc -0 ${PROJECT_NAME}_BANK_0.bin -4 ${PROJECT_NAME}_BANK_4.bin -7 ${PROJECT_NAME}_BANK_7.bin -e
)
