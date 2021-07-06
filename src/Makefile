CC=zcc
AS=z88dk-asmpp
LD=zcc

TARGET= +zx
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMSRC=$(wildcard *.asm)
CSRC=$(wildcard *.c)
BIN2REM=./bin2rem/bin2rem

CFLAGS=$(TARGET) -c \
		--codeseg=CODE_5 \
		--constseg=RODATA_5 \
		--dataseg=DATA_5 \
		--bssseg=BSS_5 \
		-clib=new \
		-pragma-include:$(PRAGMA_FILE)

LDFLAGS=$(TARGET) -crt0 crt/crt.asm -m -pragma-include:$(PRAGMA_FILE)

#ASFLAGS=-opt-speed
OBJECTS=$(CSRC:.c=.o) $(ASMSRC:.asm=.o)

# Tape files must be in the correct order and matching the 'bankTable' in crt0.asm
# loader.tap is a BASIC loader with embedded machine code bank 5 comes next as this
# has the loading screen. All other bank tape files come after in order.
TAPS:=	loader.tap \
		$(PROJ_NAME)_BANK_5.tap \
		$(PROJ_NAME)_BANK_0.tap \
		$(PROJ_NAME)_BANK_2.tap \
		$(PROJ_NAME)_BANK_7.tap

# Default to the CODE bank if no other is specified
BANK ?= BANK_2
# Find the start addres of the BANK and replace $ with 0x
HEAD=$(shell grep __$(BANK)_head *.map | awk '{gsub("^.", "0x", $$3); print $$3}')

.PHONY: all clean run dis

all: $(PROJ_NAME).tap
	@grep -E "__(CODE|RODATA|DATA|BSS)_(head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep -E "__(CODE|RODATA|DATA|BSS|code)_([0-7]|user|crt.*)_(sccz80|head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'

clean:
	rm -f *.[oid] *.tap *.bin *.map zcc_opt.inc

run: $(PROJ_NAME).tap
	fuse $<

dis: $(PROJ_NAME)_CODE.bin
	z88dk-dis -o $(HEAD) -x $(PROJ_NAME).map $(PROJ_NAME)_$(BANK).bin | less

ifeq (,$(findstring $(MAKECMDGOALS),clean))
%.d: %.asm
	@./mkdep.sh $< > $@

%.d: %.c
	@./mkdep.sh $< > $@
endif

$(BIN2REM):
	make -C bin2rem

zcc_opt.inc: $(PRAGMA_FILE)
	@echo "Creating $@"
	@cat $(PRAGMA_FILE) |  sed 's/#pragma\s*output\s*/defc /g' > $@

%.o: %.c $(PRAGMA_FILE)
	@echo "Compiling $<"
	@$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm zcc_opt.inc
	@$(AS) $(ASFLAGS) $<

$(PROJ_NAME)_CODE.bin: $(OBJECTS) $(PRAGMA_FILE)
	 @echo "Linking $@"
	 @$(LD) $(LDFLAGS) $(OBJECTS) -o $(PROJ_NAME).bin

%.tap: $(PROJ_NAME)_CODE.bin
	@echo "Creating $@"
	@z88dk-appmake $(TARGET) -b ${@:.tap=.bin} -o $@ --noloader --noheader --org 0

loader.tap: $(PROJ_NAME)_CODE.bin $(BIN2REM)
	@echo "Creating $@"
	@cat $(PROJ_NAME)_CODE.bin >> $(PROJ_NAME)_LOADER.bin
	@$(BIN2REM) $(PROJ_NAME)_LOADER.bin $@ CastleEsc

$(PROJ_NAME).tap: $(TAPS)
	@echo "Creating $@"
	@cat $+ > $@ 

-include $(ASMSRC:.asm=.d) $(CSRC:.c=.d)
