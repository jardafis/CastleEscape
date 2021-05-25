CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
CRT=31
RODATA=rodata_user
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMDEPS=	\
			$(wildcard *.inc) \
			$(wildcard *.scr) \
			$(wildcard *.afb) \
			$(wildcard *.dat) \
			$(wildcard music/*.mus) \
			$(wildcard music/*.inc) \
			$(wildcard sprite/*.inc)

C_OPT_FLAGS=-SO3

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --codesegBANK_5 --constseg$(RODATA) -compiler=sdcc -I$(Z88DK)/include/_DEVELOPMENT/sdcc -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) --codesegBANK_5 --constseg$(RODATA) -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz"--clearaddr 32767 --screen title.scr --exclude-sections bss_user"
ASFLAGS=-I$(Z88DK)/lib

OBJECTS =	$(patsubst %.c,%.o,$(wildcard *.c)) \
			$(patsubst %.asm,%.o,$(wildcard *.asm))

all: $(PROJ_NAME).tap
	@grep __BANK_5_ $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __code_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __rodata_user_ $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __data_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __bss_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@echo
	@grep __BANK_0_ $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __BANK_7_ $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile $(ASMDEPS)
	$(AS) $(ASFLAGS) $<
	
$(PROJ_NAME).tap : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(PROJ_NAME).bin -create-app
	 @rm -f *.i
	
.PHONY: clean run dis

clean:
	rm -f *.[oi] *.tap *.bin *.map *.lis *.sym

run: all
	fuse.exe $(PROJ_NAME).tap

BANK ?= CODE
HEAD=$(shell grep __$(BANK)_head *.map | awk '{gsub("^.", "0x", $$3); print $$3}')

dis: all
	z88dk-dis -o $(HEAD) -x $(PROJ_NAME).map $(PROJ_NAME)_$(BANK).bin | less
