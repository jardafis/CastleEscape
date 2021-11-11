#include <arch/zx.h>

extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char *screenTab[];
extern void printChar(unsigned char c, unsigned char x, unsigned char y) __banked;
extern void displayTile(unsigned char tile, unsigned char x, unsigned y);
extern unsigned char waitKey(void);

#define TILE_WIDTH      16
#define TILE_HEIGHT     16

/*
 * Current cursor location for displaying text to the screen.
 */
static char cursorX = 0;
static char cursorY = 0;

/*
 * Hex characters.
 */
static const char hex[] = "0123456789ABCDEF";

/*
 * Set the location for the next character printed to the screen.
 */
void setCursor(char x, char y)
{
    cursorX = x;
    cursorY = y;
}
/*
 * Start of the screen attribute memory.
 */
unsigned char *const attr = (unsigned char*) 0x5800;

/*
 * Output a 16-bit hex value.
 */
void putHex(unsigned int value)
{
    for (signed char n = 12; n >= 0; n -= 4)
    {
        printChar(hex[(value >> n) & 0xf], cursorX++, cursorY);
    }
}

/*
 * Output a string to the screen at the current x,y cursor position.
 */
void putString(char *string)
{
    while (*string)
    {
        if (*string == '\n')
        {
            cursorX = 0;
            cursorY++;
        }
        else
        {
            printChar(*string, cursorX++, cursorY);
        }
        string++;
    }
}

/*
 * Display the 12x12 tileset starting from the top left-hand side of the
 * screen.
 */
void displayTileset(const unsigned char *tiles)
{
    unsigned char tile = 0;
    for (char y = 0; y < TILE_HEIGHT; y++)
    {
        for (char x = 0; x < TILE_WIDTH; x++)
        {
            displayTile(tile++, x, y);
        }
    }
}

/*
 * Bitmap for the box cursor.
 */
const unsigned char cursor[8] =
{ 0xc3, 0x81, 0x81, 0x00, 0x00, 0x81, 0x81, 0xc3 };

/*
 * Display the box cursor at the current cursor location.
 */
void xorCursor(int x, int y)
{
    unsigned char *screenAddr = screenTab[y * 8] + x;

    for (char n = 0; n < 8; n++)
    {
        *screenAddr ^= cursor[n];
        screenAddr += 0x100;
    }
}

/*
 * Set the ink color for the current cursor location.
 */
void setInk(int x, int y, unsigned char key)
{
    attr[(y * 32) + x] = key - '0';
}

/*
 * Toggle the flash or bright attribute for the current cursor location.
 */
void toggleAttrib(int x, int y, unsigned char attrib)
{
    attr[(y * 32) + x] ^= attrib;
}

/*
 * Save the attributes from the screen to the specified location.
 */
void saveAttrib(unsigned char *dest)
{
    int x;
    int y;

    for (y = 0; y < TILE_HEIGHT; y++)
    {
        for (x = 0; x < TILE_WIDTH; x++)
        {
            *dest++ = attr[(y * 32) + x];
        }
    }
}

/*
 * Entry point for tile attribute editing in realtime.
 */
void attribEdit(unsigned char *tileset, unsigned char *attrib)
{
    int x = 0;
    int y = 0;
    unsigned char key;

    cls(INK_WHITE | PAPER_BLACK);

    displayTileset(tileset);

    setCursor(16, 0);
    putString("Up        - 'q'");
    setCursor(16, 1);
    putString("Down      - 'a'");
    setCursor(16, 2);
    putString("Left      - 'o'");
    setCursor(16, 3);
    putString("Right     - 'p'");
    setCursor(16, 4);
    putString("Bright    - 'b'");
    setCursor(16, 5);
    putString("Flash     - 'f'");
    setCursor(16, 6);
    putString("Reset     - 'r'");
    setCursor(16, 7);
    putString("Ink color - 0-7");
    setCursor(16, 8);
    putString("Exit   - <SPACE>");
    setCursor(16, 10);
    putString("Attr.");
    setCursor(16, 11);
    putString("  addr  = 0x");
    putHex((unsigned int) attrib);
    setCursor(16, 12);
    putString("  len   = 0x");
    putHex(TILE_WIDTH * TILE_HEIGHT);

    xorCursor(x, y);

    do
    {
        // Wait for key press
        key = waitKey();

        switch (key)
        {
        case 'P':                           // Right
            xorCursor(x, y);
            if (x < (TILE_WIDTH - 1))
                x++;
            xorCursor(x, y);
            break;
        case 'O':                           // Left
            xorCursor(x, y);
            if (x > 0)
                x--;
            xorCursor(x, y);
            break;
        case 'Q':                           // Up
            xorCursor(x, y);
            if (y > 0)
                y--;
            xorCursor(x, y);
            break;
        case 'A':                           // Down
            xorCursor(x, y);
            if (y < (TILE_HEIGHT - 1))
                y++;
            xorCursor(x, y);
            break;
        default:
            if (key >= '0' && key <= '7')   // Colors
            {
                setInk(x, y, key);
            }
            else if (key == 'B')            // Bright
            {
                toggleAttrib(x, y, BRIGHT);
            }
            else if (key == 'F')            // Flash
            {
                toggleAttrib(x, y, FLASH);
            }
            else if (key == 'R')            // Reset
            {
                xorCursor(x, y);
                displayTileset(tileset);
                xorCursor(x, y);
            }
            break;
        }

    } while (key != ' ');                   // SPACE to exit
    /*
     * Copy the attributes back to their original location so
     * they can be reflected in the game.
     */
    saveAttrib(attrib);
}
