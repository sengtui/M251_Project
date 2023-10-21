include ./makefile.conf

# MAIN=MyClient MyServ MyConfTool
# 列出所有含 void main(void) 程式進入點的 C 程式檔名
# 最終程式名稱與檔名相同
MAIN = MyTest

PROJECT_PATH = $(realpath ./)

IPATH =  .
IPATH += $(BASE)/Library/CMSIS/Include
IPATH += $(BASE)/Library/Device/Nuvoton/$(DEVICE)/Include
IPATH += $(BASE)/Library/StdDriver/inc
IPATH += src

BSP_DIR = ./bsplib

SRC_MAIN = $(addsuffix .c, $(MAIN))
OBJ_MAIN = $(addsuffix .o, $(MAIN))

CMSIS =  $(wildcard $(BASE)/Library/CMSIS/DSP_Lib/Source/*/*.c)
BSP = $(wildcard $(BASE)/Library/Device/Nuvoton/$(DEVICE)/Source/*.c)
BSP += $(wildcard $(BASE)/Library/Device/Nuvoton/$(DEVICE)/Source/GCC/*.c)
DRIVER = $(wildcard $(BASE)/Library/StdDriver/src/*.c)


USR = $(filter-out $(SRC_MAIN), $(wildcard src/*.c))

OBJ_BSP = $(patsubst %.c,$(BSP_DIR)/%.o,$(notdir $(BSP)))
OBJ_CMSIS = $(patsubst %.c,$(BSP_DIR)/%.o,$(notdir $(CMSIS)))
OBJ_DRIVER = $(patsubst %.c,$(BSP_DIR)/%.o,$(notdir $(DRIVER)))
OBJ_USR = $(patsubst %.c,./lib/%.o,$(notdir $(USR)))


all: MyTest

$(MAIN): bsp $(OBJ_USR) $(OBJ_BSP) $(OBJ_CMSIS) $(OBJ_DRIVER) $(OBJ_MAIN) 
	@mkdir -p ./lib
	@mkdir -p ./bin
	$(CC)  ./$@.o ./$(BSP_DIR)/*.o ./lib/*.o $(CFLAGS) $(LFLAGS) -Wl,-Map=./lib/$@.map $(STARTUP) -o ./lib/$@.axf $(addprefix -I , $(IPATH))
	$(CP) -O binary ./lib/$@.axf ./bin/$@.bin


lib/%.o: src/%.c
	@mkdir -p ./lib
	$(CC) -c $^ $(CFLAGS) -c $(addprefix -I ./, $(IPATH)) -o $@

%.o: %.c
	$(CC) -c $^ $(CFLAGS) -c $(addprefix -I ./, $(IPATH)) -o $@

bsp:
	@mkdir -p $(BSP_DIR)
	cd $(BSP_DIR) && make -f ../bsp.makefile


flash:
	openocd -f ../scripts/interface/nulink.cfg -f ../scripts/target/numicroM4.cfg -c "init" -c "reset halt" -c "flash write_image erase bin/$(MAIN).bin 0x00000000" -c "reset" -c "exit"

clean:
	rm -rf ./bin
	rm -rf ./lib
#	rm -f $(BSP_DIR)/*
	rm *.o



install: MyTest	
	cp ./bin/MyTest.bin /Volumes/NuMicro\ MCU/

debug:
	@echo $(OBJ_BSP)
	@echo $(realpath $(OBJ_BSP))
	@echo $(IPATH)
 
