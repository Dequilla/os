# Directories
SRC_DIR=src
OBJ_DIR=obj
ISO_DIR=isodir
OUT_DIR=build

# Assembler
AS=i686-elf-as
AS_SRC=$(wildcard $(SRC_DIR)/*.s)
AS_OBJ=$(subst $(SRC_DIR),$(OBJ_DIR),$(subst .s,.s.o,$(AS_SRC)))

# Compiler
CC=i686-elf-gcc
CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra
CC_SRC=$(wildcard $(SRC_DIR)/*.c)
CC_OBJ=$(subst $(SRC_DIR),$(OBJ_DIR),$(subst .c,.c.o,$(CC_SRC)))

# Linker
LFLAGS=-ffreestanding -O2 -nostdlib -lgcc
LOUT=myos.bin
LCONF=linker.ld

# ISO
IOUT=myos.iso

# Directories
directories:
	mkdir -p $(OUT_DIR) $(OBJ_DIR)

# Assembly instructions
$(OBJ_DIR)/%.s.o: $(SRC_DIR)/%.s 
	$(AS) $< -o $@ 

# Compiler instructions
$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(CC) -I./$(SRC_DIR) -o $@ -c $< $(CFLAGS)

# Link binary
build: $(AS_OBJ) $(CC_OBJ)
	$(CC) -T $(LCONF) -o $(OUT_DIR)/$(LOUT) $(LFLAGS) $(AS_OBJ) $(CC_OBJ)

# ISO
iso: directories build
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(OUT_DIR)/$(LOUT) $(ISO_DIR)/boot/$(LOUT)
	cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(OUT_DIR)/$(IOUT) $(ISO_DIR) 
	sh scripts/check-multiboot.sh

all: iso

clean:
	rm -rf $(OBJ_DIR) $(OUT_DIR) $(ISO_DIR)
