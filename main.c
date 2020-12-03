#include <stdio.h>
#include <input.h>
#include <intrinsic.h>
#include <im2.h>
#include <string.h>
#include <z80.h>
#include <arch/zx.h>
#include "screentab.h"
#include "tiled.h"

extern const unsigned char tile0[];
extern void screen;
extern unsigned char keyboardScan(void);
extern void displayScreen(void *scr);
extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char updateDirection(void)
__z88dk_fastcall;

#define JUMP_POINT_BYTE        0x81
#define TABLE_ADDR             ((void*) 0x8000)
#define JUMP_POINT             ((unsigned char*) ((JUMP_POINT_BYTE << 8) | JUMP_POINT_BYTE))

static int ticks = 0;

void isr(void);
IM2_DEFINE_ISR( isr)
{
    static unsigned char a = 0;
    zx_border(a++ & 0x7);
    ticks++;
}

void initISR(void)
{
    intrinsic_di();
    memset(TABLE_ADDR, JUMP_POINT_BYTE, 257);
    im2_init(TABLE_ADDR);
    z80_bpoke(JUMP_POINT, 0xc3);
    z80_wpoke(JUMP_POINT + 1, (unsigned int) isr);
    intrinsic_ei();
}

inline void drawTile(unsigned char tileID, unsigned char x, unsigned char y)
{
    const unsigned char *tiles = &tile0[0];
    if (tileID)
    {
        for (unsigned char n = 0; n < 8; n++)
        {
            *(screenTab[(y << 3) + n] + x) = tiles[((tileID - 1) * 8) + n];
        }
    }
}

void brick(TILE_MAP *tileMap)
{
    for (unsigned char y = 0; y < 24; y++)
    {
        for (unsigned char x = 0; x < 32; x++)
        {
            drawTile(tileMap->data[(y * 32) + x], x, y);
        }
    }
}

int main()
{
    char key = 0;
    static unsigned char dir;

    initISR();
    cls(INK_WHITE | PAPER_BLACK);
    createScreenTab();

    intrinsic_halt();
    displayScreen((void*) &screen);

    while ((key = keyboardScan()) != '\n')
    {
        intrinsic_halt();

        // Scan Q, A, O, P, SPACE and update the direction flags accordingly
        dir = updateDirection();
        if(dir)
        {
            printf("0x%02x ", dir);
        }
    }

//    printf("%c\n", key);
    intrinsic_di();
    intrinsic_im_1();
    return (0);
}
