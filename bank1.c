#include <stdio.h>
#include "screentab.h"
#ifdef __SDCC
#pragma codeseg BANK_1
#else
#pragme bank 1
#endif

char x = 0;
char y = 0;
const unsigned char *font = (unsigned char*) 0x3d00; // Address of ROM font starting at ASCII 32

void myputc(unsigned char c)
{
    if (c == '\n')
    {
        x = 0;
        y++;
    }
    else if (c == '\r')
    {
        x = 0;
    }
    else
    {
        for (char n = 0; n < 8; n++)
        {
            *(screenTab[(y << 3) + n] + x) = font[((c - ' ') << 3) + n];
        }
        x++;
    }
}

void myputs(char *string)
{
    while (*string)
    {
        myputc(*string++);
    }
}

void func2(void) __banked;
void func1(void)
{
    printf("This is func1()\n");
    printf("Calling bank 3\n");
    func2();
    printf("Returned from bank 3\n");
}

