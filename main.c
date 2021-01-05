#include <stdio.h>
#include <intrinsic.h>
#include <arch/zx.h>

#define MAX_LEVEL_X 2
#define MAX_LEVEL_Y 2
#define TILE_MAP_WIDTH  64
#define TILE_MAP_HEIGHT 24

#define PLAYER_WIDTH    8
#define PLAYER_HEIGHT   8

#define MAX_X_POS           256
#define MAX_Y_POS           192

extern const unsigned char tile0[];
extern const unsigned char tileAttr[];
extern void
attribEdit(unsigned char *tileset, unsigned char *attrib);
extern unsigned char
keyboardScan(void);
extern void
copyScreen(unsigned char xPos, unsigned char yPos, unsigned char *buffer);
extern void
pasteScreen(unsigned char xPos, unsigned char yPos, unsigned char *buffer);
extern void
displaySprite(unsigned char xPos, unsigned char yPos);

extern void border(unsigned char color)
__z88dk_fastcall;
extern void animateCoins(void *coins)
__z88dk_fastcall;
extern void gameMain(void)
__z88dk_fastcall;
extern void setCurrentTileMap()
__z88dk_fastcall;
extern void setupScreen()
__z88dk_fastcall;
extern void gameLoop()
__z88dk_fastcall;

extern void *coinTables[MAX_LEVEL_Y][MAX_LEVEL_X];

#define FIRE    0x10
#define UP      0x08
#define DOWN    0x04
#define LEFT    0x02
#define RIGHT   0x01

unsigned char buffer[16];
extern const unsigned char *currentTileMap;
extern unsigned char tileMapX;
extern unsigned char tileMapY;
extern unsigned char direction;
extern int xPos;
extern int yPos;

#define MAX_X_ACCEL     2
#define MAX_X_DECEL     4
#define MAX_X_SPEED     32
static signed char xSpeed = 0;
static signed char xAccel = 0;
static signed char xDecel = 0;

#define MAX_Y_SPEED     32
#define MAX_Y_ACCEL     4
static signed char ySpeed = 0;
static signed char yAccel = 0;

int main()
{
    int mapRow = 0;
    char key = 0;
    char jumping = 0;
    char falling = 0;
    unsigned char count = 0;

    gameMain();

    copyScreen(xPos, yPos, buffer);

    while ((key = keyboardScan()) != '\n')
    {
        gameLoop();

        border(INK_BLUE);
        if (direction & LEFT)
        {
            xDecel = 0;
            if (xAccel > -MAX_X_ACCEL)
                xAccel--;

            xSpeed = (xSpeed < -MAX_X_SPEED) ? -MAX_X_SPEED : xSpeed + xAccel;
        }
        else if (direction & RIGHT)
        {
            xDecel = 0;
            if (xAccel < MAX_X_ACCEL)
                xAccel++;

            xSpeed = (xSpeed > MAX_X_SPEED) ? MAX_X_SPEED : xSpeed + xAccel;
        }
        else
        {
            xAccel = 0;

            if (xDecel < MAX_X_DECEL)
                xDecel++;

            if (xSpeed < 0) // Moving left
            {
                xSpeed = ((xSpeed + xDecel) > 0) ? 0 : xSpeed + xDecel;
            }
            else if (xSpeed > 0) // Moving right
            {
                xSpeed = ((xSpeed - xDecel) < 0) ? 0 : xSpeed - xDecel;
            }
        }

        if (xSpeed > 0)         // Moving right
        {
            // Check for collision with solid tile
            if ((currentTileMap[((yPos >> 3) * TILE_MAP_WIDTH) + ((xPos + (PLAYER_WIDTH - 1) + (xSpeed / 16)) >> 3)] >= 144)
                    || (currentTileMap[(((yPos + (PLAYER_HEIGHT - 1)) >> 3) * TILE_MAP_WIDTH)
                            + ((xPos + (PLAYER_WIDTH - 1) + (xSpeed / 16)) >> 3)] >= 144))
            {
                // Stop movement, reset acceleration and align x position
                xSpeed = 0;
                xAccel = 0;
                xPos = (xPos + 7) & 0xfff8;
            }
            else
            {
                // Check if player had moved off the screen to the right
                if ((xPos + (xSpeed / 16)) > (MAX_X_POS - PLAYER_WIDTH))
                {
                    if (tileMapX < (MAX_LEVEL_X - 1))
                    {
                        tileMapX++;
                        xPos = 0;
                        setCurrentTileMap();
                        setupScreen();
                    }
                }
            }
        }
        else if (xSpeed < 0)    // Moving left
        {
            // Check for collision with solid tile
            if ((currentTileMap[((yPos >> 3) * TILE_MAP_WIDTH) + ((xPos + (xSpeed / 16)) >> 3)] >= 144)
                    || (currentTileMap[(((yPos + (PLAYER_HEIGHT - 1)) >> 3) * TILE_MAP_WIDTH) + ((xPos + (xSpeed / 16)) >> 3)]
                            >= 144))
            {
                // Stop movement, reset acceleration and align x position
                xSpeed = 0;
                xAccel = 0;
                xPos &= 0xfff8;
            }
            else
            {
                // Check if player had moved off the screen to the left
                if ((xPos + (xSpeed / 16)) < 0)
                {
                    if (tileMapX > 0)
                    {
                        tileMapX--;
                        xPos = MAX_X_POS - PLAYER_WIDTH;
                        setCurrentTileMap();
                        setupScreen();
                    }
                }
            }
        }

        ySpeed = ((ySpeed + yAccel) < MAX_Y_SPEED) ? ySpeed + yAccel : MAX_Y_SPEED;

        if ((currentTileMap[(((yPos + (PLAYER_HEIGHT - 1) + (ySpeed / 16)) >> 3) * 64) + (xPos >> 3)] < 144)
                && (currentTileMap[(((yPos + (PLAYER_HEIGHT - 1) + (ySpeed / 16)) >> 3) * 64) + ((xPos + (PLAYER_WIDTH - 1)) >> 3)]
                        < 144))
        {
            // Add gravity
            if (yAccel < MAX_Y_ACCEL)
                yAccel++;
        }
        else
        {
            if (direction & FIRE)
            {
                ySpeed = -MAX_Y_SPEED * 2;
            }
            else
            {
                // Stop gravity
                yAccel = 0;
                ySpeed = 0;
                falling = 0;
            }
        }

        if ((yPos + (PLAYER_HEIGHT - 1) + (ySpeed / 16)) >= MAX_Y_POS)
        {
            if (tileMapY < (MAX_LEVEL_Y - 1))
            {
                tileMapY++;
                yPos = 24;
                setCurrentTileMap();
                setupScreen();
            }
        }
        else if ((yPos + (ySpeed / 16)) < 24)
        {
            if (tileMapY > 0)
            {
                tileMapY--;
                yPos = MAX_Y_POS - PLAYER_HEIGHT;
                setCurrentTileMap();
                setupScreen();
            }
        }

        border(INK_RED);
        // Restore original contents of screen
        pasteScreen(xPos, yPos, buffer);

        // Update the player position based on speed
        xPos += (xSpeed / 16);
        yPos += (ySpeed / 16);

        border(INK_CYAN);
        // Copy contents of screen at new location
        copyScreen(xPos, yPos, buffer);

        border(INK_GREEN);
        displaySprite(xPos, yPos);

        border(INK_YELLOW);
        if (count++ >= 6)
        {
            animateCoins(coinTables[tileMapY][tileMapX]);
            count = 0;
        }

        border(INK_BLACK);
        if (key == 'S')
        {
            attribEdit(tile0, tileAttr);
            setupScreen();
        }
    }

    intrinsic_di();
    return (0);
}
