AS=/opt/vbcc/bin/vasm6502_oldstyle
LD=/opt/vbcc/bin/vlink
VI=vi
HEXDUMP=hexdump
UCSIM=/opt/sdcc/bin/ucsim_mos6502
OBJCOPY=/opt/sdcc/bin/sdobjcopy
SOCAT=socat
MINICOM=minicom
SCREEN=screen

include sources.mk

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin
INC_DIR=inc
CFG_DIR=cfg

IHX_FILE=$(BIN_DIR)/$(TARGET).ihx
MAP_FILE=$(BIN_DIR)/$(TARGET).map
LD_FILE=$(CFG_DIR)/$(TARGET).ld
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
SRC_FILE=$(SRC_DIR)/$(TARGET).asm
UC_SIM_FILE=$(CFG_DIR)/$(TARGET).ucsim

OBJS = $(patsubst $(SRC_DIR)/%.asm, $(BIN_DIR)/%.obj, $(SRCS))

AS_FLAGS=-I $(INC_DIR) -Fvobj -sect -dotdir  -wdc02
LD_FLAGS= -T$(LD_FILE) -bihex -o $(IHX_FILE) -M > $(MAP_FILE)
OBJCOPY_FLAGS= -I ihex -O binary $(IHX_FILE)
HEXDUMP_FLAGS=-C
UCSIM_FLAGS= -t 65C02 -C $(UC_SIM_FILE) -s$(VPORT0) -X 5.76768M 
SOCAT_FLAGS=-d -d PTY,link=$(VPORT0),raw,echo=0 PTY,link=$(VPORT1),raw,echo=0
MINICOM_FLAGS=-D $(VPORT1)
SCREEN_FLAGS= -S sim_uart

VPORT0=/tmp/ttyV0
VPORT1=/tmp/ttyV1

# Update your main target to depend on the final output
.PHONY: all link build edit dump clean sim bridge uart screen
all: link
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(BIN_FILE)

$(BIN_DIR)/%.obj : $(SRC_DIR)/%.asm
	$(AS) $(AS_FLAGS) -L $(@:.obj=.lst) -o $@ $<
 
build : $(OBJS)

$(IHX_FILE): $(OBJS)
	@mkdir -p $(dir $@)
	$(LD) $(LD_FLAGS) $(OBJS)

link: $(IHX_FILE)

edit:
	$(VI) $(SRC_FILE)

dump: link
	$(HEXDUMP) $(HEXDUMP_FLAGS) $(BIN_FILE)

sim: link
	$(UCSIM) $(UCSIM_FLAGS) $(IHX_FILE)

bridge:
	$(SOCAT) $(SOCAT_FLAGS) 

uart: build
	$(MINICOM) $(MINICOM_FLAGS) 

screen:
	$(SCREEN) $(SCREEN_FLAGS)

test:
	$(AS) $(AS_FLAGS) -L bin/test.lst -o bin/test.obj src/test.asm
	$(AS) $(AS_FLAGS) -L bin/parser_cmd_line.lst -o bin/parser_cmd_line.obj src/parser_cmd_line.asm
	$(AS) $(AS_FLAGS) -L bin/string.lst -o bin/string.obj src/string.asm
	$(LD) -T$(LD_FILE) -bihex -obin/test.ihx bin/test.obj bin/parser_cmd_line.obj bin/string.obj -M > bin/test.map
	$(UCSIM) $(UCSIM_FLAGS) bin/test.ihx

clean: 
	rm -f $(BIN_DIR)/*

