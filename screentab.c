#include "screentab.h"

unsigned char *screenTab[SCREEN_TAB_LEN];

void createScreenTab(void)
{
    unsigned char index = 0;

    for (int start = SCREEN_START; start < (SCREEN_START + SCREEN_LENGTH);
            start += 0x800)
    {
        for (unsigned char a = 0; a < 8; a++)
        {
            for (unsigned char n = 0; n < 8; n++)
            {
                screenTab[index++] = (char*) (start + (a << 5) + (n << 8));
            }
        }
    }
}

