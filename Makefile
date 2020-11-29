CC=zcc
TARGET=zx
CRT=0
AS=zcc

EXEC=banked.tap
EXEC_OUTPUT=banked.bin
PRAGMA_FILE=zpragma.inc

C_OPT_FLAGS=-SO3 --max-allocs-per-node200000
CFLAGS=+$(TARGET) $(C_OPT_FLAGS) -clib=sdcc_iy -c -pragma-include:$(PRAGMA_FILE)
LDFLAGS=+$(TARGET) -m -clib=sdcc_iy -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr -Cz32768
#CFLAGS=+$(TARGET) $(C_OPT_FLAGS) -O2 --list -c -pragma-include:$(PRAGMA_FILE)
#LDFLAGS=+$(TARGET) -m --list -pragma-include:$(PRAGMA_FILE) -Cz--clearaddr -Cz32768
ASFLAGS = +$(TARGET) -c -pragma-include:$(PRAGMA_FILE)

OBJECTS =  $(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.asm,%.o,$(wildcard *.asm))
#OBJECTS =  $(patsubst %.c,%.o,$(wildcard *.c))



all: $(EXEC)
 

%.o: %.c $(PRAGMA_FILE) Makefile
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.asm $(PRAGMA_FILE) Makefile
	$(AS) $(ASFLAGS) -o $@ $<
	
$(EXEC) : $(OBJECTS) $(PRAGMA_FILE) Makefile
	 $(CC) $(LDFLAGS) -startup=$(CRT) $(OBJECTS) -o $(EXEC_OUTPUT) -create-app
	
.PHONY: clean run
clean:
	rm -f *.o *.bin *.tap *.map *.lis zcc_opt.def *~ /tmp/tmpXX* $(EXEC_OUTPUT) *.sym

run: all
	fuse.exe ${EXEC}
