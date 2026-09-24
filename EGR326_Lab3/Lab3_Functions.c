#include "stm32f4xx.h"
#include <stdio.h>
#include <stdlib.h>
#include "Lab3_Functions.h"

volatile uint32_t Echo_Start = 0;										/* TIM3 count when echo went high*/
volatile uint32_t Echo_Width = 0;										/* how long echo stayed high in us*/
volatile uint8_t Echo_Done = 0;										/* 1 once we got a full pulse back*/

/***| Systick_init(void) |**************************************************************************************************************************************************************/
/* Sets SysTick up on the 16MHz clock with no interrupt so the delays below can just poll it.
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

/***| Systick_us_delay(uint16_t usdelay) |*********************************************************************************************************************************************/
/* Same thing but microseconds, used for the 10us trigger pulse.
**************************************************************************************************************************************************************************************/
void Systick_us_delay(uint16_t usdelay){
    if(usdelay == 0){return;}
    SysTick->LOAD = ((usdelay*16) - 1);								/* 16 ticks = 1us*/
    SysTick->VAL = 0;
    while((SysTick->CTRL & 0x00010000) == 0);
}

/***| Hex2Bit(uint32_t hex_num) |******************************************************************************************************************************************************/
/* Turns a pin mask like 0x40 into its pin number (6) so the MODER/AFR shifts stay readable.
**************************************************************************************************************************************************************************************/
uint8_t Hex2Bit(uint32_t hex_num){
    uint8_t bit_count = 0;
    while(hex_num>>1){
        bit_count++;
        hex_num = hex_num>>1;
    }
    return bit_count;
}

/***| Trigger_init(void) |*************************************************************************************************************************************************************/
/* PA1 as a regular push pull output, starts low so the sensor isnt triggered on boot.
**************************************************************************************************************************************************************************************/
void Trigger_init(void){
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;							/* Port A clock on*/
    GPIOA->MODER &= ~(uint32_t)(3<<(2*Hex2Bit(TRIG)));				/* clear PA1 mode*/
    GPIOA->MODER |=  (uint32_t)(1<<(2*Hex2Bit(TRIG)));				/* PA1 output*/
    GPIOA->ODR   &= ~TRIG;											/* start low*/
}

/***| Echo_Capture_init(void) |********************************************************************************************************************************************************/
/* PA6 on AF2 into TIM3 CH1. TIM3 ticks at 1MHz so every count is 1us, captures on both edges and
   fires TIM3_IRQHandler each time so we can grab the start and the end of the echo pulse.
**************************************************************************************************************************************************************************************/
void Echo_Capture_init(void){
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    GPIOA->MODER  &= ~(uint32_t)(3<<(2*Hex2Bit(ECHO)));				/* clear PA6 mode*/
    GPIOA->MODER  |=  (uint32_t)(2<<(2*Hex2Bit(ECHO)));				/* PA6 alternate function*/
    GPIOA->AFR[0] &= ~(uint32_t)(15<<(4*Hex2Bit(ECHO)));				/* clear AF bits*/
    GPIOA->AFR[0] |=  (uint32_t)(2<<(4*Hex2Bit(ECHO)));				/* AF2 = TIM3 CH1*/

    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;								/* TIM3 clock on*/
    TIM3->PSC = 16 - 1;												/* 16MHz / 16 = 1MHz, 1 count = 1us*/
    TIM3->ARR = 0xFFFF;												/* let it run the full 16 bits*/
    TIM3->CCMR1 = 0x01;												/* CH1 input, mapped to TI1*/
    TIM3->CCER = 0x0B;												/* capture on, rising AND falling edges*/
    TIM3->CNT = 0;
    TIM3->SR = 0;													/* clear any old flags*/
    TIM3->DIER |= TIM_DIER_CC1IE;									/* interrupt on capture*/
    NVIC_SetPriority(TIM3_IRQn, 1);									/* priority one*/
    NVIC_EnableIRQ(TIM3_IRQn);										/* let it through*/
    TIM3->CR1 = 1;													/* go*/
}

/***| LED_PWM_init(void) |*************************************************************************************************************************************************************/
/* PA5 on AF1 into TIM2 CH1 as PWM mode 1 at 1kHz, CCR1 from 0 to 1000 is 0% to 100%. Starts off.
**************************************************************************************************************************************************************************************/
void LED_PWM_init(void){
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    GPIOA->MODER  &= ~(uint32_t)(3<<(2*Hex2Bit(LED)));				/* clear PA5 mode*/
    GPIOA->MODER  |=  (uint32_t)(2<<(2*Hex2Bit(LED)));				/* PA5 alternate function*/
    GPIOA->AFR[0] &= ~(uint32_t)(15<<(4*Hex2Bit(LED)));
    GPIOA->AFR[0] |=  (uint32_t)(1<<(4*Hex2Bit(LED)));				/* AF1 = TIM2 CH1*/

    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;								/* TIM2 clock on*/
    TIM2->PSC = 16 - 1;												/* 1MHz*/
    TIM2->ARR = PWM_Period - 1;										/* 1kHz PWM, nice and smooth*/
    TIM2->CNT = 0;
    TIM2->CCMR1 = (6<<4)|(1<<3);									/* PWM mode 1 + preload so duty changes dont glitch*/
    TIM2->CCR1 = 0;													/* LED off to start*/
    TIM2->CCER |= 1;												/* CH1 output on*/
    if(LED_Active_Low){TIM2->CCER |= 2;}							/* invert the output so 100% still means full bright*/
    TIM2->CR1 = 1;													/* go*/
}

/***| Send_Trigger(void) |*************************************************************************************************************************************************************/
/* Clears the done flag then gives the sensor its 10us high pulse so it sends out a ping.
**************************************************************************************************************************************************************************************/
void Send_Trigger(void){
    Echo_Done = 0;													/* forget the last reading*/
    GPIOA->ODR |= TRIG;												/* high*/
    Systick_us_delay(10);											/* 10us, what the sensor wants*/
    GPIOA->ODR &= ~TRIG;											/* low, ping is out*/
}

/***| Wait_For_Echo(void) |************************************************************************************************************************************************************/
/* Waits 1ms at a time until the interrupt says the echo is done or we hit Echo_Timeout.
   Returns how many ms it waited so main can keep each loop at Loop_Time.
**************************************************************************************************************************************************************************************/
uint16_t Wait_For_Echo(void){
    uint16_t waited = 0;
    while((Echo_Done == 0) && (waited < Echo_Timeout)){
        Systick_ms_delay(1);
        waited++;
    }
    return waited;
}

/***| Echo_To_Inches(uint32_t width) |*************************************************************************************************************************************************/
/* Echo width in us to inches. Sound does ~1 inch per 74us and it goes there and back so 148us per inch.
**************************************************************************************************************************************************************************************/
float Echo_To_Inches(uint32_t width){
    return (float)width / US_Per_Inch;
}

/***| LED_Set_Duty(uint8_t percent) |**************************************************************************************************************************************************/
/* 0 to 100 percent into CCR1. 100% puts CCR1 above ARR so the pin just stays high, full blast!
**************************************************************************************************************************************************************************************/
void LED_Set_Duty(uint8_t percent){
    if(percent > 100){percent = 100;}								/* no cheating past 100*/
    TIM2->CCR1 = (percent*PWM_Period)/100;
}

/***| LED_Proximity(float inches, uint8_t *blinkptr) |*********************************************************************************************************************************/
/* Part II mapping:
   under 1 inch      -> blink at max, flips every call (250ms) so it's 2Hz
   ~1 inch           -> 100%
   2 to 9 inches     -> inches x 10%
   10 inches and up  -> off
   blinkptr remembers if the blink was on or off last time.
**************************************************************************************************************************************************************************************/
void LED_Proximity(float inches, uint8_t *blinkptr){
    uint8_t rounded;
    if(inches < 1.0f){												/* way too close, blink it!*/
        *blinkptr ^= 1;
        if(*blinkptr){LED_Set_Duty(100);}
        else{LED_Set_Duty(0);}
        return;
    }
    *blinkptr = 0;
    if(inches >= (Max_Inches - 0.5f)){								/* rounds to 10+, lights out*/
        LED_Set_Duty(0);
        return;
    }
    rounded = (uint8_t)(inches + 0.5f);								/* nearest inch*/
    if(rounded <= 1){LED_Set_Duty(100);}								/* ~1 inch, max bright*/
    else{LED_Set_Duty(rounded*10);}									/* 2 -> 20%, 3 -> 30% ... 9 -> 90%*/
}

/***| TIM3_IRQHandler(void) |**********************************************************************************************************************************************************/
/* Runs on every echo edge. If the pin is high it was the rising edge so save the start, if it's
   low it was the falling edge so width = end - start. The & 0xFFFF handles the counter wrapping.
**************************************************************************************************************************************************************************************/
void TIM3_IRQHandler(void){
    uint32_t current;
    if(TIM3->SR & TIM_SR_CC1IF){
        current = TIM3->CCR1;										/* reading CCR1 clears CC1IF too*/
        if(GPIOA->IDR & ECHO){										/* rising edge*/
            Echo_Start = current;
        }
        else{														/* falling edge, we got it*/
            Echo_Width = (current - Echo_Start) & 0xFFFF;
            Echo_Done = 1;
        }
    }
    TIM3->SR &= ~TIM_SR_CC1OF;										/* clear overcapture just in case*/
}
