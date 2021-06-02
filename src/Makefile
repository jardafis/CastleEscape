CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMDEPS=	\
			$(wildcard *.inc) \
			$(wildcard *.scr) \
			$(wildcard *.dat) \
			$(wildcard music/*.mus) \
			$(wildcard music/*.inc) \
			$(wildcard sprite/*.inc) \
			$(wildcard crt/*.asm)

CODE=CODE_5
RODATA=RODATA_5
DATA=DATA_5
BSS=BSS_5

C_OPT_FLAGS=-SO2

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --codeseg=$(CODE) --constseg=$(RODATA) --dataseg=$(DATA) --bssseg=$(BSS) -I$(Z88DK)/include/_DEVELOPMENT/sccz80 -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) -crt0 crt/crt.asm -m \
	-pragma-include:$(PRAGMA_FILE) \
	-create-app -Cz"--clearaddr 32767 --screen title.scr --exclude-sections 'bss_user BSS_0 BSS_1 BSS_2 BSS_3 BSS_4 BSS_5 BSS_6 BSS_7'"
#ASFLAGS=-opt-speed

OBJECTS =	$(patsubst %.c,%.o,$(wildcard *.c)) \
			$(patsubst %.asm,%.o,$(wildcard *.asm))

all: $(PROJ_NAME).tap
	@grep -E "__.*_([0-7]|user|crt.*)_(init|main|exit|sccz80|head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile $(ASMDEPS)
	$(AS) $(ASFLAGS) $<
	
$(PROJ_NAME).tap : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) $(OBJECTS) -o $(PROJ_NAME).bin
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
