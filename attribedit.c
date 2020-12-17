#include <intrinsic.h>
#include <arch/zx.h>

extern unsigned char keyboardScan(void)
__z88dk_fastcall;
extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char *screenTab[];
extern const unsigned char tile0[];
extern const unsigned char tileAttr[];

void displayTileset(void)
{
    int x;
    int y;
    int n;
    const unsigned char *tiles = &tile0[0];
    unsigned char *screenAddr;

    for (y = 0; y < 12; y++)
    {
        for (x = 0; x < 12; x++)
        {
            screenAddr = screenTab[y * 8] + x;
            for (n = 0; n < 8; n++)
            {
                *screenAddr = *tiles++;
                screenAddr += 0x100;
            }
        }
    }

}

const unsigned char cursor[8] =
{ 0xff, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0xff };

void xorCursor(int x, int y)
{
    unsigned char *screenAddr = screenTab[y * 8] + x;
    int n;

    for (n = 0; n < 8; n++)
    {
        *screenAddr ^= cursor[n];
        screenAddr += 0x100;
    }

}

void setAttrib(int x, int y, unsigned char key)
{
    unsigned volatile char *attr = (unsigned char*) 0x5800;

    attr[(y * 32) + x] = key - '0';
}

void toggleAttrib(int x, int y, unsigned char attrib)
{
    unsigned volatile char *attr = (unsigned char*) 0x5800;

    attr[(y * 32) + x] ^= attrib;
}

void saveAttrib(void)
{
    int x;
    int y;
    unsigned volatile char *dest = (unsigned char*) 0xc000;
    unsigned volatile char *attr = (unsigned char*) 0x5800;

    for (y = 0; y < 12; y++)
    {
        for (x = 0; x < 12; x++)
        {
            *dest++ = attr[(y * 32) + x];
        }
    }
}

void loadAttrib(void)
{
    int x;
    int y;
    unsigned char *dest = (unsigned char*) 0x5800;
    const unsigned char *attr = &tileAttr[0];

    for (y = 0; y < 12; y++)
    {
        for (x = 0; x < 12; x++)
        {
            dest[(y * 32) + x] = *attr++;
        }
    }
}

void attribEdit(void)
{
    int x = 0;
    int y = 0;
    unsigned char key;
    intrinsic_di();

    cls(INK_WHITE | PAPER_BLACK);

    loadAttrib();

    displayTileset();

    xorCursor(x, y);

    do
    {
        while ((key = keyboardScan()) == 0)
            ;
        // Wait for key release
        while (keyboardScan() != 0)
            ;

        switch (key)
        {
        case 'P':
            xorCursor(x, y);
            if (x < 11)
                x++;
            xorCursor(x, y);
            break;
        case 'O':
            xorCursor(x, y);
            if (x > 0)
                x--;
            xorCursor(x, y);
            break;
        case 'Q':
            xorCursor(x, y);
            if (y > 0)
                y--;
            xorCursor(x, y);
            break;
        case 'A':
            xorCursor(x, y);
            if (y < 11)
                y++;
            xorCursor(x, y);
            break;
        default:
            if (key >= '0' && key <= '7')
            {
                setAttrib(x, y, key);
            }
            else if (key == 'B')
            {
                toggleAttrib(x, y, 0x40);
            }
            else if (key == 'F')
            {
                toggleAttrib(x, y, 0x80);
            }
            else if (key == 'R')
            {
                loadAttrib();
            }
            break;
        }

    } while (key != ' ');
    saveAttrib();
}
