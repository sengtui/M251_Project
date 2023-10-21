/**
 * @file param.h
 * @author 
 * @brief 
 * @version 0.1
 * @date 2023-06-20
 * 
 * @details 所有的定義職定義值都放這裡，所以所有的程式都應該要 include "param.h"
 * 另外，所有會跟其他程式共用的全域變數建議都放在 param.c, 然候在 param.h 最後段宣告 extern 變數，這樣子方便大家取用。
 * @copyright Copyright (c) 2023
 * 
 */
#ifndef PARAM_H_
#define PARAM_H_

#define PLL_CLOCK 48000000
#define true  1
#define false 0
#define PI 3.14159265

#include "NuMicro.h"

#define APROM_TEST_BASE   0x3000
#define DATA_FLASH_BASE   0x30000
#define DATA_FLASH_END    0x3FFFF

#define RXBUFSIZE   256
#define TXBUFSIZE   256

#endif /* PARAM_H_ */


// 所有定義在 PARAM.C 的全域變數在這邊宣告 extern, 讓引用這個 PARAM.H 的檔案都可以 access 到全域變數
#ifndef _PARAM_C_

extern int16_t DB[256];
extern volatile uint32_t ticks;


#endif