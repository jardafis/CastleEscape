#include <stdio.h>
#include <intrinsic.h>
#include <arch/zx.h>
#include "tiled.h"

extern unsigned char *screenTab[];
extern const unsigned char tile0[];
extern const unsigned char screen[];
extern unsigned char keyboardScan(void);
extern void displayScreen(void *scr);
extern void copyScreen(unsigned char xPos, unsigned char yPos,
        unsigned char *buffer);
extern void pasteScreen(unsigned char xPos, unsigned char yPos,
        unsigned char *buffer);
extern void displaySprite(unsigned char xPos, unsigned char yPos);
extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char updateDirection(void)
__z88dk_fastcall;
extern void scroll(void)
__z88dk_fastcall;
extern void scrollInit(void *message)
__z88dk_fastcall;
void initISR(void)
__z88dk_fastcall;
void border(unsigned char color)
__z88dk_fastcall;

#define FIRE    0x10
#define UP      0x08
#define DOWN    0x04
#define LEFT    0x02
#define RIGHT   0x01

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

unsigned char buffer[16];

int main()
{
    int xPos = 0;
    int yPos = 0;
    char key = 0;
    static unsigned char dir;

    initISR();
    cls(INK_WHITE | PAPER_BLACK);
    border(INK_BLACK);

    intrinsic_halt();
    displayScreen(&screen[0]);

    copyScreen(xPos, yPos, buffer);

    scrollInit(NULL);

    while ((key = keyboardScan()) != '\n')
    {
//        intrinsic_halt();
        intrinsic_halt();
        border(INK_WHITE);

        // Scroll the message
        scroll();

        // Restore original contents of screen
        pasteScreen(xPos, yPos, buffer);

        // Scan Q, A, O, P, SPACE and update the direction flags accordingly
        dir = updateDirection();

        //
        // Check for collisions and clear the direction bits accordingly
        //

        // Update to new position based on direction bits
        if (dir & UP)
        {
            if (yPos)
                yPos -= 1;
        }
        else if (dir & DOWN)
        {
            if (yPos < (192 - 8))
                yPos += 1;
        }

        if (dir & LEFT)
        {
            if (xPos >= 2)
                xPos -= 2;
        }
        else if (dir & RIGHT)
        {
            if (xPos < (256 - 8))
                xPos += 2;
        }

        if (dir & FIRE)
        {
            ;
        }

        // Copy contents of screen at new location
        copyScreen(xPos, yPos, buffer);

        displaySprite(xPos, yPos);

        border(INK_BLACK);
    }

    intrinsic_di();
    return (0);
}
