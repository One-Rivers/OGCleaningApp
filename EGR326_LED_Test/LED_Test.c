/* EGR326 shield LED check, Juan Rios.
   Flips all four LED pins high for 2 sec then low for 2 sec, forever.
   The orange LED on PA5 is the reference since it's wired PA5 -> resistor -> LED -> GND, so it's on during the HIGH half.
   Shield LEDs: D1A/D2A/D3A (anodes) go to PA8/PA9/PA10 and D1C/D2C/D3C (cathodes) go to GND, so they light with the orange one.
   If a shield LED never lights, it's dead or flipped, swap its A and C wires to double check.
   Works on the F411 or the F446 since GPIOA and SysTick are the same on both.
*/
#include "stm32f4xx.h"
#include <stdint.h>

/*Pins, all Port A so life stays simple
****************************************************************************************************************************************************************************************/
#define ORANGE (uint32_t) 0x0020										/* PA5, the external orange LED from Lab 3*/
#define BLUE   (uint32_t) 0x0100										/* PA8, to D1A (blue D1 anode)*/
#define GREEN  (uint32_t) 0x0200										/* PA9, to D2A (green D2 anode)*/
#define RED    (uint32_t) 0x0400										/* PA10, to D3A (red D3 anode)*/
#define ALL_LEDS (ORANGE|BLUE|GREEN|RED)								/* the whole squad*/

void Systick_init(void);
void Systick_ms_delay(uint16_t msdelay);
uint8_t Hex2Bit(uint32_t hex_num);
void LEDs_init(void);

int main(void){
    Systick_init();													/* Systick Initialization*/
    LEDs_init();													/* all four pins as outputs*/

    while(1){
        GPIOA->ODR |= ALL_LEDS;										/* HIGH half, orange should be glowing!*/
        Systick_ms_delay(1000);
        Systick_ms_delay(1000);										/* two 1 sec delays since one tops out around 1 sec*/
        GPIOA->ODR &= ~ALL_LEDS;									/* LOW half, orange goes dark*/
        Systick_ms_delay(1000);
        Systick_ms_delay(1000);
    }
}

/***| Systick_init(void) |**************************************************************************************************************************************************************/
/* Sets SysTick up on the 16MHz clock with no interrupt so the delay can just poll it.
**************************************************************************************************************************************************************************************/
void Systick_init(void){
    SysTick->CTRL = 0;												/* off while we set it up*/
    SysTick->LOAD = 0x00FFFFFF;										/* max reload*/
    SysTick->VAL = 0;												/* any write clears it*/
    SysTick->CTRL = 0x00000005;										/* on, 16MHz, no interrupt*/
}

/***| Systick_ms_delay(uint16_t msdelay) |*********************************************************************************************************************************************/
/* Blocking delay in milliseconds. Tops out around 1048ms since LOAD is only 24 bits.
**************************************************************************************************************************************************************************************/
void Systick_ms_delay(uint16_t msdelay){
    if(msdelay == 0){return;}										/* 0 would underflow LOAD, just bail*/
    SysTick->LOAD = ((msdelay*16000) - 1);							/* 16000 ticks = 1ms*/
    SysTick->VAL = 0;												/* clears VAL and COUNTFLAG*/
    while((SysTick->CTRL & 0x00010000) == 0);						/* wait for COUNTFLAG*/
}

/***| Hex2Bit(uint32_t hex_num) |******************************************************************************************************************************************************/
/* Turns a pin mask like 0x0400 into its pin number (10) so the MODER shifts stay readable.
**************************************************************************************************************************************************************************************/
uint8_t Hex2Bit(uint32_t hex_num){
    uint8_t bit_count = 0;
    while(hex_num>>1){
        bit_count++;
        hex_num = hex_num>>1;
    }
    return bit_count;
}

/***| LEDs_init(void) |****************************************************************************************************************************************************************/
/* Turns on the Port A clock and makes PA5, PA8, PA9 and PA10 regular push pull outputs, all starting low.
**************************************************************************************************************************************************************************************/
void LEDs_init(void){
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;							/* Port A clock on*/
    GPIOA->MODER &= ~(uint32_t)((3<<(2*Hex2Bit(ORANGE)))|(3<<(2*Hex2Bit(BLUE)))|(3<<(2*Hex2Bit(GREEN)))|(3<<(2*Hex2Bit(RED))));	/* clear all four modes*/
    GPIOA->MODER |=  (uint32_t)((1<<(2*Hex2Bit(ORANGE)))|(1<<(2*Hex2Bit(BLUE)))|(1<<(2*Hex2Bit(GREEN)))|(1<<(2*Hex2Bit(RED))));	/* all outputs, easy*/
    GPIOA->ODR &= ~ALL_LEDS;										/* start low*/
}
