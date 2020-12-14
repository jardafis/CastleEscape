CC=zcc
AS=asmpp.pl
LD=zcc
TARGET=zx
CRT=31

EXEC=mixed.tap
EXEC_OUTPUT=mixed.bin
PRAGMA_FILE=zpragma.inc

#C_OPT_FLAGS=-SO2 --max-allocs-per-node200000
C_OPT_FLAGS=-SO2

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --legacy-banking -clib=sdcc_iy -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr -Cz32767
ASFLAGS=-I$(Z88DK)/lib

OBJECTS =  $(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.asm,%.o,$(wildcard *.asm)) tiles/tiles.o

all: $(EXEC)

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile
	$(AS) $(ASFLAGS) $<
	
$(EXEC) : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(EXEC_OUTPUT) -create-app
	
.PHONY: clean run dis

clean:
	rm -f $(OBJECTS) $(EXEC) $(EXEC_OUTPUT) *.bin *.map *.lis *.sym *.i

run: all
	fuse.exe ${EXEC}

dis: all
	z88dk-dis -o 0x8184 -x mixed.map mixed_CODE.bin | less
