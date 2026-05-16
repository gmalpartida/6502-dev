AS=/opt/sdcc/bin/sdas6500
LD=/opt/sdcc/bin/sdld
VI=vi
HEXDUMP=hexdump
UCSIM=/opt/sdcc/bin/ucsim_mos6502

TARGET=$(notdir $(CURDIR))

SRC_DIR=src
BIN_DIR=bin
INC_DIR=inc
CFG_DIR=cfg

LST_FILE=$(BIN_DIR)/$(TARGET).lst
OBJ_FILE=$(BIN_DIR)/$(TARGET).o
SRC_FILE=$(SRC_DIR)/$(TARGET).asm
CFG_FILE=$(CFG_DIR)/$(TARGET).cfg
MAP_FILE=$(BIN_DIR)/$(TARGET).map
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
LD_FILE=$(SRC_DIR)/$(TARGET).ld
UC_SIM_FILE=$(CFG_DIR)/$(TARGET).ucsim
REL_FILE=$(BIN_DIR)/$(TARGET).rel
IHX_FILE=$(BIN_DIR)/$(TARGET).ihx

AS_FLAGS=-los -I$(INC_DIR) $(REL_FILE) 
LD_FLAGS= -i
HEXDUMP_FLAGS=-C
UCSIM_FLAGS= -t 65C02 -C $(UC_SIM_FILE)

.PHONY: all build edit dump clean sim

all: link

link: build
	$(LD) $(LD_FLAGS) $(REL_FILE)

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

