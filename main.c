#include <stdio.h>
#include <input.h>
#include <intrinsic.h>
#ifndef __SDCC
#include <spectrum.h>
#else
#include <im2.h>
#include <string.h>
#include <z80.h>
#include <arch/zx.h>
#endif
#include "screentab.h"
#include "brick.h"

#ifdef __SDCC
extern void myputs(char *string);
extern void myputc(char c) __banked ;
#else
extern void myputs(char *string)
__banked;
extern void myputc(char c)
__banked;
#endif

extern void brick1(void);

#define JUMP_POINT_BYTE        0x81
#define TABLE_ADDR             ((void*) 0x8000)
#define JUMP_POINT             ((unsigned char*) ((JUMP_POINT_BYTE << 8) | JUMP_POINT_BYTE))

static int ticks = 0;

#ifndef __SDCC
int writebyte(int fd, int c)
{

}
#endif

#ifdef __SDCC
void isr(void);
IM2_DEFINE_ISR( isr)
#else
void isr(void)
#endif
{
    static unsigned char a = 0;
    zx_border(a++ & 0x7);
    ticks++;
}

void initISR(void)
{
#ifdef __SDCC
    intrinsic_di();
    memset(TABLE_ADDR, JUMP_POINT_BYTE, 257);
    im2_init(TABLE_ADDR);
    z80_bpoke(JUMP_POINT, 0xc3);
    z80_wpoke(JUMP_POINT + 1, (unsigned int) isr);
    intrinsic_ei();
#else
    intrinsic_di();
    zx_im2_init(TABLE_ADDR, 0x81);
    im1_install_isr(isr);
    intrinsic_ei();
#endif
}

void brick(void)
{
    for (int x = 0; x < 32; x++)
    {

        for (char n = 0; n < 8; n++)
        {
            *(screenTab[(0 << 3) + n] + x) = MagickImage[7 + n];
        }

    }
    for (int x = 0; x < 32; x++)
    {
        for (char n = 0; n < 8; n++)
        {
            *(screenTab[(23 << 3) + n] + x) = MagickImage[7 + n];
        }
    }
}

void func1(void) __banked;

extern int bankedtapeloader() __z88dk_fastcall;
int main()
{
    int start, end;
    char key = 0;

//    bankedtapeloader();

    initISR();
#ifdef __SDCC
    zx_cls(INK_WHITE | PAPER_BLACK);
#else
    zx_cls();
    zx_colour(INK_WHITE | PAPER_BLACK);
#endif
    createScreenTab();

    printf("\n\n");
    printf("Calling bank 1\n");
    func1();
    printf("Returned from bank 1\n");

    intrinsic_halt();
    start = ticks;
    brick();
    end = ticks;
    printf("%d\n", end - start);

    intrinsic_halt();
    start = ticks;
    brick1();
    end = ticks;
    printf("%d\n", end - start);
#ifdef __SDCC
    while ((key = in_inkey()) == 0)
#else
    while ((key = in_Inkey()) == 0)
#endif
    {
        intrinsic_halt();
    }
    myputc(key);
    intrinsic_di();
    intrinsic_im_1();
    return (0);
}
