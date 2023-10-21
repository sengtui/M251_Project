# NUVOTON M453 PICO2 PROJECT

# 安裝開發環境(Linux)

## 設定開發目錄
例如： >mkdir NuMicro-M4



## 下載 原廠SDK (BSP檔)並且解壓縮到開發目錄
```shell
> cd NuMicro-M4/
> unzip en-us--M451_Series_BSP_CMSIS_V3.01.006.zip
```
## 下載 Tool-chain Cross-Compiler 
有開發過 PICO 的就一定不陌生，其實，你電腦裡頭的 arm-gcc 已經可以直接使用喔！！！ 
檢查一下有沒有 arm-none-eabi-gcc 這一系列的 gcc cross compiler, 並且確定有放在$PATH路徑，或是在 Makefile 路徑有指定好。
沒有下載過的可以用這個連結下載：https://developer.arm.com/downloads/-/gnu-rm

## 在 NuMicro-M4/ 目錄下建立 makefile.conf
記得把 BASE 的目錄設成 BSP 的目錄。 個人建議把BSP 目錄改得簡單點，例如
```shell
mv en-us--M451_Series_BSP_CMSIS_V3.01.006 M451BSP
```
如果你不想要編譯 project 的時候被一堆落落長路徑字串塞滿整個視窗的話。

```makefile
# Selecting Core
CORTEX_M=4
# Use newlib-nano. To disable it, specify USE_NANO=
USE_NANO=--specs=nano.specs
# Use seimhosting or not
USE_SEMIHOST=--specs=rdimon.specs
USE_NOHOST=--specs=nosys.specs
CORE=CM$(CORTEX_M)
BASE=../M451BSP
DEVICE=M451Series
# Compiler & Linker
CC=arm-none-eabi-gcc
CXX=arm-none-eabi-g++
# Binary
CP=arm-none-eabi-objcopy

# Options for specific architecture
#ARCH_FLAGS=-mthumb -mcpu=cortex-m$(CORTEX_M) 
ARCH_FLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -D __FPU_PRESENT -mfpu=fpv4-sp-d16
# Startup code
STARTUP=$(BASE)/Library/Device/Nuvoton/$(DEVICE)/Source/GCC/startup_$(DEVICE).S

# -Os -flto -ffunction-sections -fdata-sections to compile for code size
CFLAGS=$(ARCH_FLAGS) $(STARTUP_DEFS) -Os -flto -ffunction-sections -fdata-sections
CXXFLAGS=$(CFLAGS)

# Link for code size
GC=-Wl,--gc-sections

# Create map file
MAP=-Wl,-Map=$(NAME).map
```

## 把專案 Clone 回去吧！！ （這裡 clone 到 MyTest目錄，也可以直接用 pico2 目錄啦，不過個人認為有點俗
```shell
git clone https://gitlab.com/pioneerm/Server_Edge/pico2.git MyTest
```
## 進去專案
```shell
> cd MyTest
> make
```
## 大功完成， 開始使用吧！！

# 腳位介紹

### 實驗設計腳位： PXY_ZZZ  
- X 為 GPIO word, 分為 A, B, C, D, E， 
- Y 為位元，可為 0~15。 
- Z 是為了方便記憶加註功能名稱

PXY 為實際腳位，可以在手冊中查到封裝的對應腳位編號

### 程式用到的腳位
- DEBUG printf 用的 uart0: PD0_RXD, PD1_TXD
- T1, T2 PTO 實驗： PD3_T2, PD7_T1
- ADC 實驗： PB5_ADC13, PB15_ADC12
- DAC 實驗： PB0_DAC
- DI 實驗： PB1, PB2, PB3 (分別是 A, B, Z)
- DQ 實驗: 使用 PD3_T1, PD2_T2 時鐘輸出來模擬
- T3_EXT 脈衝寬度實驗： PE1_T3_EXT 還沒測試
- RS485 實驗：(P58)PA9_RXD3, (P57)PA8_TXD3, (P85)PA14_DIR3 還沒寫
- CAN BUS 實驗：(P45)PC1_CAN_RX, (P44)PC0_CAN_TX, (P43)PC14 還沒寫
- I2C實驗:(P82)PA0_SCCLK (P81)PA1_SCDAT還沒寫

### 安裝須知
- 因為目標 CPU 是 M453，所以做硬體測試請使用 M451(453) 開發版，電源設定為 5V， 勿使用481 開發版。
- DEBUG printf 用的 uart0: (P8)PD0_RXD, (P15)PD1_TXD 請手動接到 Nu-Maker 除錯板

# 測試項目

## SERVO DRIVE DI 實驗

1. 將 SERVO DRIVE 的 DO+ 經過二極體接到 GPIO (P92)PB1, (P93)PB2, (P94)PB3， GPIO 腳使用 6.8K Pull High
2. DO- 接到 SERVO DRIVE 本身的 COM-， COM- 同時要接到開發版的 GND
3. 介面電路請參考 KiCAD 電路原理圖的左下角（數位輸入PULL HIGH For Servo(NPN) DQs）
#### 實驗內容
- 測量 SERVO DO 輸出/關閉時 GPIO 腳的電壓，並且用示波器觀察升降緣與servo 運轉時雜訊
- 移除二極體，直接將 DO+ 接到 GPIO, 測量SERVO DO 輸出/關閉時 GPIO 腳的電壓，並且用示波器觀察升降緣與servo 運轉時雜訊
- 在程式中加上 debounce filter, 檢驗並找到抗干擾效果和延遲檢出之間的平衡點
#### 實驗目標
- 依照 二極體壓降 和 雜訊 決定是否取消二極體（或改為 Clamp 電路，僅處理低於 0V或高於 5V)
- 決定是否在一般 DI 導入 debounce , 杜絕雜訊干擾的可能性

## SERVO ENCODER 實驗
1. 將 SERVO DRIVE 的 OA, OA-, OB, OB-, OZ, OZ- 透過 4ch RS485 receiver 接入 GPIO PB1, PB2, PB3
2. 運轉 servo motor 在不同速度，觀察 GPIO 收到的波形和雜訊，並且驗證程式 (四倍頻雙向計數器)
3. 找到較好的終端阻抗（目前為 500 Ohm)，可以嘗試 250 / 330 / 680 / 1K, 並且用示波器觀察波形差異，可嘗試開啟 Schmitt 觸發功能看看效果如何
```c
// Schmitt 觸發的開關沒有寫成 macro, 需要自己修改 bit, 就拿 debounce 的設定來改：
#define GPIO_ENABLE_DEBOUNCE(port, u32PinMask)		   ((port)->DBEN |= (u32PinMask))

#define GPIO_ENABLE_SCHMITT	(port, u32PinMask)		   ((port)->SMTEN |= (u32PinMask))

```
#### 實驗目標
- 決定終端阻抗
- 決定四倍頻/兩倍頻計數器
- 決定是否開啟 schmitt 觸發功能，並且了解開啟後頻率上限

## PLC_DO DI 實驗

1. 將 PLC 的 DQ 經10K電阻接到 GPIO (P92)PB1, (P93)PB2, (P94)PB3， GPIO 腳使用 6.8K Pull low to GND, 接點要接二極體 clamp high to 5V
2. PLC GND 接到 開發版的 GND
3. 介面電路請參考 KiCAD 電路原理圖的左下角（數位輸入PULL LOW For PLC(PNP) DQs）
#### 實驗內容
- 測量 PLC DQ 輸出/關閉時 GPIO 腳的電壓，並且用示波器觀察升降緣與servo 運轉時雜訊
- 移除二極體，並且直接將 DQ 接到 GPIO, 測量PLC DQ H/L時 GPIO 腳的電壓，並且用示波器觀察升降緣與servo 運轉時雜訊 (小心別燒掉開發版的 GPIO)
- 在程式中加上 debounce filter, 檢驗並找到抗干擾效果和延遲檢出之間的平衡點
#### 實驗目標
- 依照 雜訊 決定是否以 Clamp 電路切5V 上限，或是調整電阻使 24V 輸入時GPIO 電壓僅略高於 5V（代價是電流較小，容易受干擾，且輸入點電壓低於 12V 時可能無法讀到正確值）
- 決定是否開啟 schmitt 觸發功能
- 決定是否在一般 DI 導入 debounce , 杜絕雜訊干擾的可能性

## printf("DEBUG printf 用的 uart0: (P8)PD0_RXD, (P15)PD1_TXD\n");
## printf("T1, T2 PTO 實驗： (P12)PD3_T2, (P32)PD7_T1\n");
## printf("ADC 實驗： (P4)PB5_ADC13, (P3)PB15_ADC12\n");
## printf("DAC 實驗： (P91)PB0_DAC\n");
## printf("DQ 實驗: 使用 PD3_T1, PD2_T2 時鐘輸出來模擬\n");
## printf("PWM 實驗: 用 DAC 讀值換成 PWM ratio 以後送到 LED 輸出，還沒開始寫\n");
## printf("T3_EXT 脈衝寬度實驗： (P65)PE1_T3_EXT 還沒測試\n");
## printf("RS485 實驗：(P58)PA9_RXD3, (P57)PA8_TXD3, (P85)PA14_DIR3 還沒寫\n");
## printf("CAN BUS 實驗：(P45)PC1_CAN_RX, (P44)PC0_CAN_TX, (P43)PC14 正在寫\n");
## printf("I2C實驗:(P82)PA0_SCCLK (P81)PA1_SCDAT還沒寫\n");
