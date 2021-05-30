CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
CRT=31
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
CODE=CODE_5
RODATA=RODATA_5
DATA=DATA_5
BSS=BSS_5

C_OPT_FLAGS=-SO3

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --codeseg=$(CODE) --constseg=$(RODATA) --dataseg$(DATA) --bssseg$(BSS) -I$(Z88DK)/include/_DEVELOPMENT/sccz80 -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) -crt0 crt/crt.asm --codesegBANK_5 --constseg$(RODATA) -m -pragma-include:$(PRAGMA_FILE) -Cz"--clearaddr 32767 --screen title.scr --exclude-sections 'bss_user BSS_0 BSS_1 BSS_2 BSS_3 BSS_4 BSS_5 BSS_6 BSS_7'"
ASFLAGS=-I$(Z88DK)/lib

OBJECTS =	$(patsubst %.c,%.o,$(wildcard *.c)) \
			$(patsubst %.asm,%.o,$(wildcard *.asm))

all: $(PROJ_NAME).tap
	@grep "^__.*_5_" $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __code_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __rodata_user_ $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __data_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep __bss_user_ $(PROJ_NAME).map | 	awk '{printf "%-24s = %s\n", $$1, $$3}'
	@echo
	@grep "^__.*_0_" $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep "^__.*_7_" $(PROJ_NAME).map | 		awk '{printf "%-24s = %s\n", $$1, $$3}'

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
