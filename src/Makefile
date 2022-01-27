ifeq ($(OS),Windows_NT)
SUFFIX=.exe
else
SUFFIX=
endif

CC=zcc
AS=z88dk-z80asm
LD=zcc

TARGET?= +zx
PROJECT_NAME=CastleEscape
ASMSRC=$(wildcard *.asm)
CSRC=$(wildcard *.c)
ZXSTLC=./tools/zxstlc$(SUFFIX)

CFLAGS=$(TARGET) -O2 -c \
		--codeseg=CODE_4 \
		--constseg=RODATA_4 \
		--dataseg=DATA_4 \
		--bssseg=BSS_4 \
		-clib=new

LDFLAGS=$(TARGET) --no-crt -m crt/crt.asm

ifeq ($(TARGET),+zxn)
ZXEMU=zesarux
EMUFLAGS= --machine TBBlue --configfile .zesaruxrc --tbblue-fast-boot-mode  --nosplash --nowelcomemessage --quickexit
ASFLAGS+=-mz80n -D_ZXN
CFLAGS+=-D_ZXN
DISFLAGS+=-mz80n
else
ZXEMU=fuse
ASFLAGS+=-mz80
DISFLAGS+=-mz80
endif

OBJECTS=$(CSRC:.c=.o) $(ASMSRC:.asm=.o)

# Default to the CODE bank if no other is specified
BANK ?= BANK_2
# Find the start addres of the BANK and replace $ with 0x
HEAD=$(shell grep __$(BANK)_head *.map | awk '{gsub("^.", "0x", $$3); print $$3}')
MAIN=$(shell ./getMain.sh)

.PHONY: all clean run dis

all: $(PROJECT_NAME).tap
	@grep -E "__(CODE|RODATA|DATA|BSS|HEAP)_(head|tail|size).*" $(PROJECT_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'
	@grep -E "__(CODE|RODATA|DATA|BSS|HEAP|code)_([0-7]|user|crt.*)_(sccz80|head|tail|size).*" $(PROJECT_NAME).map | awk '{printf "%-24s = %s\n", $$1, $$3}'

clean:
	rm -f *.[od] *.tap *.bin *.map *.dsk *.zx0

run: $(PROJECT_NAME).tap
	$(ZXEMU) $(EMUFLAGS) $<

rundsk: $(PROJECT_NAME).dsk
	$(ZXEMU) $(EMUFLAGS) $<

dis: $(PROJECT_NAME)_BANK_2.bin
	z88dk-dis $(DISFLAGS) -o $(HEAD) -x $(PROJECT_NAME).map $(PROJECT_NAME)_$(BANK).bin | less

ifeq (,$(findstring $(MAKECMDGOALS),clean))
%.d: %.asm
	@./mkdep.sh $< > $@

%.d: %.c
	@./mkdep.sh $< > $@
endif

mainmenu.scr.zx0: mainmenu.scr
	z88dk-zx0 -f -q $<

%.o: %.c
	@echo "Compiling $<"
	@$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm
	@echo "Assembling $<"
	@$(AS) $(ASFLAGS) $<

$(PROJECT_NAME)_BANK_2.bin: $(OBJECTS) crt/crt.asm
	@echo "Linking $@"
	@$(LD) $(LDFLAGS) $(OBJECTS) -o $(PROJECT_NAME)

$(PROJECT_NAME).bin: $(PROJECT_NAME)_BANK_2.bin
	@echo "Creating $@"
	@cp ${PROJECT_NAME}_BANK_5.bin ${PROJECT_NAME}.bin
	@dd if=/dev/null of=${PROJECT_NAME}.bin bs=1 count=1 seek=8K
	@cat ${PROJECT_NAME}_BANK_2.bin >> ${PROJECT_NAME}.bin
	@dd if=/dev/null of=${PROJECT_NAME}.bin bs=1 count=1 seek=24K
	@cat ${PROJECT_NAME}_BANK_0.bin >> ${PROJECT_NAME}.bin

$(PROJECT_NAME).tap: $(PROJECT_NAME).bin title.scr
	@echo "Creating $@"
	$(ZXSTLC) -t $(PROJECT_NAME).bin 24576 $(MAIN) -l title.scr -n CastleEsc -4 $(PROJECT_NAME)_BANK_4.bin -e

$(PROJECT_NAME).dsk: $(PROJECT_NAME).bin title.scr
	@echo "Creating $@"
	$(ZXSTLC) -d $(PROJECT_NAME).bin 24576 $(MAIN) -l title.scr -4 $(PROJECT_NAME)_BANK_4.bin -e

-include $(ASMSRC:.asm=.d) $(CSRC:.c=.d)
