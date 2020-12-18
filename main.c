#include <stdio.h>
#include <intrinsic.h>
#include <arch/zx.h>

extern unsigned char *screenTab[];
extern const unsigned char tile0[];
extern const unsigned char tileAttr[];
extern const unsigned char screen[];
extern void attribEdit(unsigned char *tileset, unsigned char *attrib);
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

void brick(unsigned char *tileMap)
{
    for (unsigned char y = 0; y < 24; y++)
    {
        for (unsigned char x = 0; x < 32; x++)
        {
            drawTile(tileMap[(y * 32) + x], x, y);
        }
    }
}

unsigned char buffer[16];
unsigned char *tileMapData = &screen[0];
int main()
{
    int xPos = 40;
    int yPos = 40;
    char key = 0;
    static unsigned char dir;

    initISR();

    // Setup the screen and border
    cls(INK_WHITE | PAPER_BLACK);
    border(INK_BLACK);
    displayScreen(&screen[0]);
    scrollInit(NULL);

    copyScreen(xPos, yPos, buffer);

    while ((key = keyboardScan()) != '\n')
    {
        intrinsic_halt();
        for(int a = 0; a<256; a++); // Delay so we can see the border on screen

        border(INK_WHITE);
        // Scroll the message
        scroll();

        border(INK_MAGENTA);
        // Scan Q, A, O, P, SPACE and update the direction flags accordingly
        dir = updateDirection();

        border(INK_RED);
        // Restore original contents of screen
        pasteScreen(xPos, yPos, buffer);

        //
        // Check for collisions and clear the direction bits accordingly
        //

        border(INK_BLUE);
        // Update to new position based on direction bits
        if (dir & UP)
        {
            if (yPos)
            {
                if ((tileMapData[(((yPos - 1) >> 3) * 32) + (xPos >> 3)] == 0xff)
                        && (tileMapData[(((yPos - 1) >> 3) * 32)
                                + ((xPos + 7) >> 3)] == 0xff))
                    yPos -= 1;
            }
        }
        else if (dir & DOWN)
        {
            if (yPos < (192 - 8))
            {
                if ((tileMapData[(((yPos + 7 + 1) >> 3) * 32) + (xPos >> 3)]
                        == 0xff)
                        && (tileMapData[(((yPos + 7 + 1) >> 3) * 32)
                                + ((xPos + 7) >> 3)] == 0xff))
                    yPos += 1;
            }
        }

        if (dir & LEFT)
        {
            if (xPos >= 2)
            {
                if ((tileMapData[((yPos >> 3) * 32) + ((xPos - 2) >> 3)] == 0xff)
                        && (tileMapData[(((yPos + 7) >> 3) * 32)
                                + ((xPos - 2) >> 3)] == 0xff))
                    xPos -= 2;
            }
        }
        else if (dir & RIGHT)
        {
            if (xPos < (256 - 8))
            {
                if ((tileMapData[((yPos >> 3) * 32) + ((xPos + 7 + 2) >> 3)]
                        == 0xff)
                        && (tileMapData[(((yPos + 7) >> 3) * 32)
                                + ((xPos + 7 + 2) >> 3)] == 0xff))
                    xPos += 2;
            }
        }

        if (dir & FIRE)
        {
            ;
        }

        border(INK_YELLOW);
        // Copy contents of screen at new location
        copyScreen(xPos, yPos, buffer);

        border(INK_CYAN);
        displaySprite(xPos, yPos);

        border(INK_BLACK);
        if (key == 'S')
        {
            attribEdit(tile0, tileAttr);
            cls(INK_WHITE | PAPER_BLACK);
            displayScreen(&screen[0]);
            scrollInit(NULL);
        }
    }

    intrinsic_di();
    return (0);
}
