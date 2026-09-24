#include "stm32f4xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#ifndef Lab3_Functions_H_
#define Lab3_Functions_H_

/*Pins, all on Port A so life stays simple
****************************************************************************************************************************************************************************************/
#define TRIG (uint32_t) 0x02											/* PA1, plain GPIO out that pokes the sensor*/
#define LED  (uint32_t) 0x20											/* PA5, TIM2 CH1 PWM, the glowy one (D13 header)*/
#define ECHO (uint32_t) 0x40											/* PA6, TIM3 CH1 input capture, 5V goes through the level shifter first*/

/*Numbers we keep reusing
****************************************************************************************************************************************************************************************/
#define PWM_Period 1000												/* 1MHz / 1000 = 1kHz PWM, no flicker*/
#define US_Per_Inch 148.0f											/* sound round trip, ~148us per inch*/
#define Echo_Timeout 40												/* ms, sensor maxes out ~38ms so 40 is chill*/
#define Loop_Time 250												/* ms per loop, toggling every 250ms = 2Hz blink*/
#define Print_Loops 8												/* 8 x 250ms = print every 2 sec*/
#define Max_Inches 10												/* 10 inches and up, LED goes off*/
#define Out_Of_Range 99.0f											/* fake distance for when nothing came back*/

/*Stuff the TIM3 interrupt writes to
****************************************************************************************************************************************************************************************/
extern volatile uint32_t Echo_Start;
extern volatile uint32_t Echo_Width;
extern volatile uint8_t Echo_Done;

/*Systick Functions********************************************
*/
void Systick_init(void);
void Systick_ms_delay(uint16_t msdelay);
void Systick_us_delay(uint16_t usdelay);
uint8_t Hex2Bit(uint32_t hex_num);

/*Set up Functions********************************************
*/
void Trigger_init(void);
void Echo_Capture_init(void);
void LED_PWM_init(void);

/*Sensor Functions********************************************
*/
void Send_Trigger(void);
uint16_t Wait_For_Echo(void);
float Echo_To_Inches(uint32_t width);

/*LED Functions********************************************
*/
void LED_Set_Duty(uint8_t percent);
void LED_Proximity(float inches, uint8_t *blinkptr);

/*Interrupts********************************************
*/
void TIM3_IRQHandler(void);

#endif /* Lab3_Functions_H_ */
