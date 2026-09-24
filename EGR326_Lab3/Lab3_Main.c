/* EGR326 Lab 3 - Capture and Compare with the STM32F446
   Juan Rios
   Part I:  HC-SR04 proximity sensor, TIM3 input capture measures the echo, prints distance every 2 sec
   Part II: LED on TIM2 PWM gets brighter/dimmer with distance, blinks at 2Hz under 1 inch
   Wiring:  TRIG -> PA1, ECHO -> level shifter -> PA6, LED1C (D1) or LED3C (D3) -> PA5, sensor on 5V
*/
#include "stm32f4xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "Lab3_Functions.h"

int main(void){
    Systick_init();													/* Systick Initialization*/
    Trigger_init();													/* PA1 trigger out*/
    Echo_Capture_init();											/* PA6 + TIM3 capture*/
    LED_PWM_init();													/* PA5 + TIM2 PWM*/
    __enable_irq();													/* interrupts on*/
    Systick_ms_delay(50);											/* let the sensor wake up*/

    uint8_t Blink = 0;												/* blink state for under 1 inch*/
    uint8_t *BlinkPTR = &Blink;
    uint8_t Loops = 0;												/* counts loops till the next print*/
    uint16_t Waited;												/* how long we waited on the echo*/
    float Inches;

    printf("EGR326 Lab 3 - Proximity Sensor\n");

    while(1){
        Send_Trigger();												/* ping!*/
        Waited = Wait_For_Echo();

        if(Echo_Done){Inches = Echo_To_Inches(Echo_Width);}		/* got one back*/
        else{Inches = Out_Of_Range;}								/* nothing there*/

        LED_Proximity(Inches, BlinkPTR);							/* Part II*/

        Loops++;
        if(Loops >= Print_Loops){									/* every 2 sec, Part I*/
            Loops = 0;
            if(Inches < Out_Of_Range){printf("Distance: %.2f in\n", Inches);}
            else{printf("Distance: out of range\n");}
        }

        Systick_ms_delay(Loop_Time - Waited);						/* keeps every loop at 250ms*/
    }
}
