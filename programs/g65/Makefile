AS=ca65
LD=ld65
VI=vi
HEXDUMP=hexdump

AS_FLAGS=-g -I inc/ --verbose -l bin/g65.lst -o bin/g65.o
LD_FLAGS= -C cfg/g65.cfg -m bin/g65.map -o bin/g65.bin
HEXDUMP_FLAGS=-C

all: link

link: build
	$(LD) $(LD_FLAGS) bin/g65.o
build:
	$(AS) $(AS_FLAGS) src/g65.asm
edit:
	$(VI) src/g65.asm
dump: link
	$(HEXDUMP) $(HEXDUMP_FLAGS) bin/g65.bin
clean:
	rm bin/*
