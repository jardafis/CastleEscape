/*
 * tiled.h
 *
 */

#ifndef TILED_H_
#define TILED_H_

/**
 * Structure for binary tile maps.
 */
typedef struct
{
    unsigned char orientation;
    unsigned char staggerAxis;
    unsigned char staggerIndex;
    unsigned int hexSideLength;
    unsigned int mapWidth;
    unsigned int mapHeight;
    unsigned int tileWidth;
    unsigned int tileHeight;
    unsigned char tileNumBits;
    unsigned char RLE;
    unsigned int layerCount;
    unsigned int data[];
} TILE_MAP;

#endif /* TILED_H_ */
