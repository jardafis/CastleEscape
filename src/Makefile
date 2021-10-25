CC=zcc
AS=z88dk-asmpp
LD=zcc

TARGET= +zx
PROJ_NAME=CastleEscape
PRAGMA_FILE=zpragma.inc
ASMSRC=$(wildcard *.asm)
CSRC=$(wildcard *.c)
ZXSTLC=~/zxstlc/zxstlc_linux

CFLAGS=$(TARGET) -O2 -c \
		--codeseg=CODE_5 \
		--constseg=RODATA_5 \
		--dataseg=DATA_5 \
		--bssseg=BSS_5 \
		-clib=new \
		-pragma-include:$(PRAGMA_FILE)

LDFLAGS=$(TARGET) -crt0 crt/crt.asm -m -pragma-include:$(PRAGMA_FILE)

#ASFLAGS=-opt-speed
OBJECTS=$(CSRC:.c=.o) $(ASMSRC:.asm=.o)

# Default to the CODE bank if no other is specified
BANK ?= BANK_2
# Find the start addres of the BANK and replace $ with 0x
HEAD=$(shell grep __$(BANK)_head *.map | awk '{gsub("^.", "0x", $$3); print $$3}')

.PHONY: all clean run dis

all: $(PROJ_NAME).tap
	@grep -E "__(CODE|RODATA|DATA|BSS)_(head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep -E "__(CODE|RODATA|DATA|BSS|code)_([0-7]|user|crt.*)_(sccz80|head|tail|size).*" $(PROJ_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'

clean:
	rm -f *.[oid] *.tap *.bin *.map *.dsk zcc_opt.inc

run: $(PROJ_NAME).tap
	fuse $<

dis: $(PROJ_NAME)_BANK_2.bin
	z88dk-dis -o $(HEAD) -x $(PROJ_NAME).map $(PROJ_NAME)_$(BANK).bin | less

ifeq (,$(findstring $(MAKECMDGOALS),clean))
%.d: %.asm
	@./mkdep.sh $< > $@

%.d: %.c
	@./mkdep.sh $< > $@
endif

zcc_opt.inc: $(PRAGMA_FILE)
	@echo "Creating $@"
	@cat $(PRAGMA_FILE) |  sed 's/#pragma\s*output\s*/defc /g' > $@

%.o: %.c $(PRAGMA_FILE)
	@echo "Compiling $<"
	@$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm zcc_opt.inc
	@$(AS) $(ASFLAGS) $<

$(PROJ_NAME)_BANK_2.bin: $(OBJECTS) $(PRAGMA_FILE)
	 @echo "Linking $@"
	 @$(LD) $(LDFLAGS) $(OBJECTS) -o $(PROJ_NAME).bin

$(PROJ_NAME).tap: $(PROJ_NAME)_BANK_2.bin
	@echo "Creating $@"
	@dd if=/dev/null of=$(PROJ_NAME)_BANK_5.bin bs=1 count=1 seek=8192
	#@dd if=/dev/null of=$(PROJ_NAME)_BANK_2.bin bs=1 count=1 seek=16384
	@cat $(PROJ_NAME)_BANK_5.bin > $(PROJ_NAME).bin
	@cat $(PROJ_NAME)_BANK_2.bin >> $(PROJ_NAME).bin
	#@cat $(PROJ_NAME)_BANK_0.bin >> $(PROJ_NAME).bin
	$(ZXSTLC) -b $(PROJ_NAME).bin 24576 24576 -l title.scr -n CastleEsc -0 $(PROJ_NAME)_BANK_0.bin -7 $(PROJ_NAME)_BANK_7.bin

-include $(ASMSRC:.asm=.d) $(CSRC:.c=.d)
