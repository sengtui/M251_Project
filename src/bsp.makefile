BSP_BASE= ../../M251BSP

include ../makefile.conf

IPATH = -I ./$(BSP_BASE)/Library/CMSIS/Include
IPATH += -I ./$(BSP_BASE)/Library/Device/Nuvoton/$(DEVICE)/Include
IPATH += -I ./$(BSP_BASE)/Library/StdDriver/inc

CMSIS =  $(wildcard $(BSP_BASE)/Library/CMSIS/DSP_Lib/Source/*/*.c)
BSP = $(wildcard $(BSP_BASE)/Library/Device/Nuvoton/$(DEVICE)/Source/*.c)
BSP += $(wildcard $(BSP_BASE)/Library/Device/Nuvoton/$(DEVICE)/Source/GCC/*.c)
DRIVER = $(wildcard $(BSP_BASE)/Library/StdDriver/src/*.c)


OBJ_CMSIS = $(patsubst %.c,./%.o,$(notdir $(CMSIS)))
OBJ_BSP = $(patsubst %.c,./%.o,$(notdir $(BSP)))
OBJ_DRIVER = $(patsubst %.c,./%.o,$(notdir $(DRIVER)))

all: $(OBJ_CMSIS) $(OBJ_BSP) $(OBJ_DRIVER)

$(OBJ_CMSIS): $(CMSIS)
	 $(CC) $^ $(CFLAGS) -c  $(IPATH)

$(OBJ_BSP): $(BSP)
	$(CC) $^ $(CFLAGS) -c  $(IPATH)

$(OBJ_DRIVER): $(DRIVER)
	$(CC) $^ $(CFLAGS) -c  $(IPATH)

debug:
	@echo "OBJ_CMSIS=" $(OBJ_CMSIS)
	@echo "OBJ_BSP=" $(OBJ_BSP)
	@echo "OBJ_DRIVER=" $(OBJ_DRIVER)
	@echo "IPATH=" $(IPATH)
	@echo "CFLAGS=" $(CFLAGS)


clean:
	rm -f *.o


