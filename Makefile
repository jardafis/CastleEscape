CC=zcc
AS=zcc
LD=zcc
TARGET=zx
CRT=31

EXEC=mixed.tap
EXEC_OUTPUT=mixed.bin
PRAGMA_FILE=zpragma.inc

C_OPT_FLAGS=-SO2 --max-allocs-per-node200000

CFLAGS=+$(TARGET) $(C_OPT_FLAGS) --legacy-banking --list -clib=sdcc_iy -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr -Cz32768
ASFLAGS=+$(TARGET) --list -c -pragma-include:$(PRAGMA_FILE)

OBJECTS =  $(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.asm,%.o,$(wildcard *.asm)) tiles/tiles.o

all: $(EXEC)

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile
	$(AS) $(ASFLAGS) -o $@ $<
	
$(EXEC) : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(LD) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(EXEC_OUTPUT) -create-app
	
.PHONY: clean run
clean:
	rm -f $(OBJECTS) $(EXEC) $(EXEC_OUTPUT) *.bin *.map *.lis *.sym

run: all
	fuse.exe ${EXEC}
