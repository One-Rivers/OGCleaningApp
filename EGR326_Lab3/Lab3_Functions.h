#include "stm32f4xx.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#ifndef Lab3_Functions_H_
#define Lab3_Functions_H_

/*Pins, all on Port A so life stays simple
****************************************************************************************************************************************************************************************/
#define TRIG (uint32_t) 0x02											/* PA1, plain GPIO out that pokes the sensor*/
#define LED  (uint32_t) 0x20											/* PA5, TIM2 CH1 PWM, jumper LED1C (blue D1) or LED3C (red D3) to this, the glowy one*/
#define ECHO (uint32_t) 0x40											/* PA6, TIM3 CH1 input capture, 5V goes through the level shifter first*/

/*2N7000 level shifter
****************************************************************************************************************************************************************************************/
#define Shifter_Inverts 0												/* 0 = ECHO goes through Q1 then Q2, Q2 flips it right back so PA6 just follows ECHO,
															   TRIG comes straight off PA1 since 3.3V is plenty for the sensor
															   1 = only one 2N7000 inverter per line, these macros flip it back in code instead*/
#if Shifter_Inverts
#define Trig_High (GPIOA->ODR &= ~TRIG)									/* PA1 low -> inverter off -> TRIG pulled up to 5V*/
#define Trig_Low  (GPIOA->ODR |=  TRIG)									/* PA1 high -> inverter on -> TRIG yanked to GND*/
#define Echo_Is_High ((GPIOA->IDR & ECHO) == 0)							/* ECHO high -> inverter on -> PA6 reads low, so low means high lol*/
#else
#define Trig_High (GPIOA->ODR |=  TRIG)
#define Trig_Low  (GPIOA->ODR &= ~TRIG)
#define Echo_Is_High ((GPIOA->IDR & ECHO) != 0)
#endif

/*Numbers we keep reusing
****************************************************************************************************************************************************************************************/
#define LED_Active_Low 0												/* flip to 1 if LEDxC is the cathode side and the LED acts backwards*/
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

/*printf goes out USART2********************************************
*/
int fputc(int ch, FILE *f);

#endif /* Lab3_Functions_H_ */
