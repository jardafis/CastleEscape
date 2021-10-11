# Castle Escape - An IrataHack Production

A ZX Spectrum game written using [Z88DK](https://github.com/z88dk/z88dk) for [FUSE](http://fuse-emulator.sourceforge.net) (but should work on a real ZX Spectrum 128K, +2, +3).

## Credits

* Coding - [IrataHack](mailto:iratahack@digitalxfer.com)
* Graphics - Supported by [Carnivac](https://zxart.ee/eng/authors/c/carnivac/)
* Music - Borrowed from [WYZTracker](https://github.com/AugustoRuiz/WYZTracker)
* Sound Effects - Created using [WYZTracker](https://github.com/AugustoRuiz/WYZTracker)
* Levels - Designed with [Tiled](https://www.mapeditor.org/)
* PNG to SCR - Converted with [PNG-to-SCR](https://github.com/MatejJan/PNG-to-SCR)
* Boot Loader - Created with BIN2REM Version 2.1, by Paolo Ferraris (pieffe8_at_libero.it)

## Synopsis

Wee Knight must escape the haunted castle collecting gold coins and dodging the castles deadly inhabitants as he goes. Due to the enormous weight of his armor, Wee Knight cannot jump very high unless he consumes the purple eggs found within the castle. But beware, the anti-gravity effects of the eggs do not last long leaving Wee Knight at risk of missing out on the castles many treasures. Prolong life by collecting the hearts and don’t let Wee Knight fall too far or he'll be crushed by the weight of his own armor.

## User Controls

* Default Keys (can be redefined)
  * O - Left
  * P - Right
  * SPACE - Jump
* Joysticks
  * Kempston

## Latest Release

The latest release can be downloaded from [here](https://github.com/iratahack/CastleEscape/releases/tag/latest) as a *.tap* file. Remember to switch FUSE into 128K mode as this is a 128K game.

## Game Images

The larger images include the ZX Spectrum border, smaller images do not.

![Title](assets/title.png "SCREEN$") ![Main Menu](assets/mainmenu.png "Main Menu")

### In-game Play

![Level 1](assets/level1.png "Level 1") ![Level 2](assets/level2.png "Level 2")

### Level Map

The game consists 24 levels arranged in a 4x6 grid, shown below.

![Level Map](assets/tiled/levels.png "Level Map")

## Building Sources

The latest version of Z88DK must be in the path. Install Z88DK from the Snap Store with the commands
below or by following the instructions [here](https://github.com/z88dk/z88dk/wiki/installation).

```sh
sudo snap install --edge z88dk

sudo snap alias z88dk.zcc zcc
sudo snap alias z88dk.z88dk-asmpp z88dk-asmpp
sudo snap alias z88dk.z88dk-asmstyle z88dk-asmstyle
sudo snap alias z88dk.z88dk-appmake z88dk-appmake
sudo snap alias z88dk.z88dk-dis z88dk-dis
```

From the cloned repo use the command below to build and run the game.

```sh
make -C ./src/ run
```

The result of the build should be a *CastleEscape.tap* (tape image) file in the *src* directory which can be loaded and executed with a ZX Spectrum emulator.

### Make Targets

* *assets* Directory
  * clean - remove all derived files
  * all - build the asset files
  * install - Copy the asset files to the src directory
* *src* Directory
  * clean - remove all derived files
  * all - build *CastleEscape.tap* file
  * dis - build and disassemble
    * Add 'BANK=&lt;bankname&gt;' to disassemble a specific bank, the default is BANK_2
  * run - build and run with FUSE which must be on the path
