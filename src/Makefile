CC=zcc
AS=asmpp.pl
LD=zcc

TARGET=zx
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMSRC=$(wildcard *.asm)
CSRC=$(wildcard *.c)

C_OPT_FLAGS=-SO2

CFLAGS=+$(TARGET) -c \
		$(C_OPT_FLAGS) \
		--codeseg=CODE_5 \
		--constseg=RODATA_5 \
		--dataseg=DATA_5 \
		--bssseg=BSS_5 \
		-I$(Z88DK)/include/_DEVELOPMENT/sccz80 \
		-pragma-include:$(PRAGMA_FILE)

LDFLAGS=+$(TARGET) -crt0 crt/crt.asm -m \
	-pragma-include:$(PRAGMA_FILE) \
	-create-app -Cz"--clearaddr 32767 \
					--screen title.scr \
					--exclude-sections 'bss_user BSS_0 BSS_1 BSS_2 BSS_3 BSS_4 BSS_5 BSS_6 BSS_7'"
#ASFLAGS=-opt-speed

OBJECTS=$(CSRC:.c=.o) $(ASMSRC:.asm=.o)

# Default to the CODE bank is no other is specified
BANK ?= CODE
# Find the start addres of the BANK and replace $ with 0x
HEAD=$(shell grep __$(BANK)_head *.map | awk '{gsub("^.", "0x", $$3); print $$3}')

.PHONY: clean run dis

all: $(PROJ_NAME).tap
	@grep -E "__.*_([0-7]|user|crt.*)_(init|main|exit|sccz80|head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'

clean:
	rm -f *.[oid] *.tap *.bin *.map *.lis *.sym

run: $(PROJ_NAME).tap
	fuse.exe $<

dis: all
	z88dk-dis -o $(HEAD) -x $(PROJ_NAME).map $(PROJ_NAME)_$(BANK).bin | less

ifeq (,$(findstring $(MAKECMDGOALS),clean))
%.d: %.asm
	@./mkdep.sh $< > $@

%.d: %.c
	@./mkdep.sh $< > $@
endif

%.o: %.c $(PRAGMA_FILE) Makefile
	@echo "Compiling $<"
	@$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile
	@$(AS) $(ASFLAGS) $<
	
$(PROJ_NAME).tap : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) $(OBJECTS) -o $(PROJ_NAME).bin
	 @rm -f *.i

-include $(ASMSRC:.asm=.d) $(CSRC:.c=.d)
