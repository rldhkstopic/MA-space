#define F_CPU 16000000U
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#define LCD_INST (*(volatile unsigned char *)0x8000)
#define LCD_DATA (*(volatile unsigned char *)0x8002)

void LCD_data(char ch) 
{
	LCD_DATA = ch; // Write data
	_delay_us(50);
}
void LCD_comm(char ch)
{
	LCD_INST=ch; // Write instruction
	_delay_ms(5);
}
void LCD_CHAR(char c) // Display one character
{
	LCD_data(c); 
}
void LCD_STR(char *str) // Display a string
{
	while(*str)
	LCD_CHAR(*str++);
}
void LCD_pos(char col, char row) // Start position
{
	LCD_comm(0x80|(col+row*0x40)); 
}
void LCD_clear(void)
{
	LCD_comm(1);
}
void LCD_init(void) 
{
	LCD_comm(0x38); // Function Set: Data line 8bit, 5X8 dot, 2 Line
	LCD_comm(0x0C); // Display ON/OFF
	LCD_comm(0x06); // Entry Mode Set: 
	LCD_clear();
}
int main(void)
{
	char str[20]="LCD test..      ";
	MCUCR = 0x80; // Address and data bus
	LCD_init(); 
	LCD_pos(0,0);
	sprintf(str,"Hello");
	LCD_STR(str);
	LCD_pos(0,1);
	sprintf(str,"World");
	LCD_STR(str);
	while(1);
}


