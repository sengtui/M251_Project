#include "utils.h"
#include "string.h"
#include "MCU_Init.h"

/**
 * @brief Sleep n ms
 * 
 * @param ms 
 */
void Sleep_ms(uint32_t ms)
{
    int i;

    for (i=0; i<ms; i++) {
        CLK_SysTickDelay(1000);
    }
}

