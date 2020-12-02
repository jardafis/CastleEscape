/*
 * screentab.h
 *
 */

#ifndef SCREENTAB_H_
#define SCREENTAB_H_

#define SCREEN_START	0x4000
#define SCREEN_LENGTH	0x1800
#define SCREEN_TAB_LEN	192

extern unsigned char *screenTab[SCREEN_TAB_LEN];
extern void createScreenTab(void);

#endif
