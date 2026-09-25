/* EGR326 Lab 3 - Capture and Compare with the STM32F446, Juan Rios.
   The HC-SR04 gets pinged every 250ms and TIM3 input capture on PA6 times the echo to get the distance in inches.
   Every 2 seconds that distance gets printed out USART2 to the ST-Link COM port at 9600 baud.
   The LED on PA5 runs off TIM2 PWM, 10% brightness per inch up to 9 inches, off at 10 and up, and a 2Hz blink under 1 inch.
   TRIG comes straight off PA1 since 3.3V is plenty for the sensor.
   ECHO goes through two 2N7000s back to back so PA6 only ever sees 3.3V and the signal still isnt flipped.
*/
#include "stm32f4xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "Lab3_Functions.h"
#include "USART.h"

int main(void){
    USART_Init();													/* USART2 for printf, gotta be first so we can see stuff*/
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
