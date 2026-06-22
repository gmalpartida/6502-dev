AS=/opt/vbcc/bin/vasm6502_oldstyle
LD=/opt/vbcc/bin/vlink
VI=vi
HEXDUMP=hexdump
UCSIM=/opt/sdcc/bin/ucsim_mos6502
OBJCOPY=/opt/sdcc/bin/sdobjcopy

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin
INC_DIR=inc
CFG_DIR=cfg

LST_FILE=$(BIN_DIR)/$(TARGET).lst
OBJ_FILE=$(BIN_DIR)/$(TARGET).o
SRC_FILE=$(SRC_DIR)/$(TARGET).asm
MAP_FILE=$(BIN_DIR)/$(TARGET).map
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
LD_FILE=$(CFG_DIR)/$(TARGET).ld
UC_SIM_FILE=$(CFG_DIR)/$(TARGET).ucsim
IHX_FILE=$(BIN_DIR)/$(TARGET).ihx

AS_FLAGS=-I $(INC_DIR) -wdc02 -Fvobj -sect -wfail -dotdir -L $(LST_FILE) -o $(OBJ_FILE) 
LD_FLAGS= -T$(LD_FILE) -bihex -o $(IHX_FILE) -M > $(MAP_FILE)
HEXDUMP_FLAGS=-C
UCSIM_FLAGS= -t 65C02 -C $(UC_SIM_FILE)
OBJCOPY_FLAGS= -I ihex -O binary $(IHX_FILE)

.PHONY: all build edit dump clean sim

all: link

link: build
	$(LD) $(LD_FLAGS) $(OBJ_FILE)
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(BIN_FILE)
build:
	@mkdir -p $(BIN_DIR)
	$(AS) $(AS_FLAGS) $(SRC_FILE)
edit:
	$(VI) $(SRC_FILE)
dump: link
	$(HEXDUMP) $(HEXDUMP_FLAGS) $(BIN_FILE)
sim: link
	$(UCSIM) $(UCSIM_FLAGS) $(IHX_FILE)
clean:
	rm -rf $(BIN_DIR)/*

