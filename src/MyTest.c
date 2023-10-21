/**
 * @file MyTest480.c
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2023-06-17
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#include <stdio.h>
#include "NuMicro.h"
#include "MCU_Init.h"
#include "param.h"
#include "utils.h"

int main()
{

   // 韌體模組，指定時脈，腳位設定.... 
    SYS_Init();     // 初始化 MCU (MCU_Init.c)
    //GPIO_Init();    // 初始化 GPIO/PWM 功能 (MCU_Init.c)

    /* Init UART0 to 115200-8n1 for print message */
    SYS_ResetModule(UART0_RST);
    UART_SetLine_Config(UART0, 115200, UART_WORD_LEN_8, UART_PARITY_NONE, UART_STOP_BIT_1);
    UART_Open(UART0, 115200);

    printf("\nHello!!\n");
    printf("\n CPU Clock = %d, HXT Clock = %d, Stable: %s\n",CLK_GetCPUFreq(), CLK_GetHXTFreq(), (CLK->STATUS & CLK_STATUS_HXTSTB_Msk)?"True":"False");

    while(1){
    }
}

uint32_t ProcessHardFault(uint32_t u32_lr, uint32_t u32msp, uint32_t u32psp)
{
    uint32_t u32exception_num;
    uint32_t u32r0, u32r1, u32r2, u32r3, u32r12, u32lr, u32pc, u32psr, *pu32sp;

    if (u32_lr & 4)
        pu32sp = (uint32_t *)u32psp;
    else
        pu32sp = (uint32_t *)u32msp;

    /* Get information from stack */
    u32r0  = pu32sp[0];
    u32r1  = pu32sp[1];
    u32r2  = pu32sp[2];
    u32r3  = pu32sp[3];
    u32r12 = pu32sp[4];
    u32lr  = pu32sp[5];
    u32pc  = pu32sp[6];
    u32psr = pu32sp[7];


    /* Check T bit of psr */
    if ((u32psr & (1 << 24)) == 0)
    {
        printf("PSR T bit is 0.\nHard fault caused by changing to ARM mode!\n");

        while (1);
    }

    /* Check hard fault caused by ISR */
    u32exception_num = u32psr & xPSR_ISR_Msk;

    if (u32exception_num > 0)
    {
        /*
        Exception number
            0 = Thread mode
            1 = Reserved
            2 = NMI
            3 = HardFault
            4-10 = Reserved11 = SVCall
            12, 13 = Reserved
            14 = PendSV
            15 = SysTick, if implemented[a]
            16 = IRQ0.
                .
                .
            n+15 = IRQ(n-1)[b]
            (n+16) to 63 = Reserved.
        The number of interrupts, n, is 32
        */

        printf("Hard fault is caused in IRQ #%u\n", u32exception_num - 16);

        while (1);
    }

    printf("Hard fault location is at 0x%08x\n", u32pc);
    /*
        If the hard fault location is a memory access instruction, You may debug the load/store issues.

        Memory access faults can be caused by:
            Invalid address - read/write wrong address
            Data alignment issue - Violate alignment rule of Cortex-M processor
            Memory access permission - MPU violations or unprivileged access (Cortex-M0+)
            Bus components or peripheral returned an error response.
    */

    printf("r0  = 0x%x\n", u32r0);
    printf("r1  = 0x%x\n", u32r1);
    printf("r2  = 0x%x\n", u32r2);
    printf("r3  = 0x%x\n", u32r3);
    printf("r12 = 0x%x\n", u32r12);
    printf("lr  = 0x%x\n", u32lr);
    printf("pc  = 0x%x\n", u32pc);
    printf("psr = 0x%x\n", u32psr);

    while (1);
}
