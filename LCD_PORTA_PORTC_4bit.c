/* PORTA4:D4, PORTA5:D5, PORTA6:D6, PORTA7:D7 */
/* PORTC0:E, PORTC1:RS, GND:R/W */
//#define F_CPU 16000000U
#include <avr/io.h>
//#include <util/delay.h>
#include <stdio.h>
#define LCD_DATA PORTA //LCD데이터 포트 정의
#define LCD_INST PORTA
#define LCD_CTRL PORTC //LCD제어 포트 정의
#define RS 0x01
#define EN 0x00 
void delay_us(unsigned char time_us)
{ 
	register unsigned char i;
	for(i=0;i<time_us;i++) //4 cycle
	{
		asm volatile("PUSH R0"); //2 cycle
		asm volatile("POP R0"); //2 cycle
		asm volatile("PUSH R0"); //2 cycle
		asm volatile("POP R0"); //2 cycle
		asm volatile("PUSH R0"); //2 cycle
		asm volatile("POP R0"); //2 cycle
		// Sum = 16 cycle=1 us for 16MHz
	}
}
void delay_ms(unsigned int time_ms)
{
	register unsigned int i;
	for(i=0;i<time_ms;i++) //4 cycle
	{
		delay_us(250);
		delay_us(250);
		delay_us(250);
		delay_us(250);
	}
}
char flip_bits(char ch)
{
	char return_ch=0;
	return_ch=(ch>>3) & 0x10;
	return_ch=return_ch | ((ch>>1) & 0x20);
	return_ch=return_ch | ((ch<<1) & 0x40);
	return_ch=return_ch | ((ch<<3) & 0x80);
	return return_ch;
}
void LCD_data(char ch)
{
	LCD_DATA=flip_bits(ch); //upper nibble 데이터 출력
	LCD_CTRL |= (1<<RS);
	LCD_CTRL |= 1<<EN;
	delay_us(1);
	LCD_CTRL &= ~(1<<EN);
	delay_us(20);
	
	LCD_DATA=flip_bits(ch<<4); //lower nibble 데이터 출력
	LCD_CTRL |= (1<<RS);
	LCD_CTRL |= 1<<EN;
	delay_us(1);
	LCD_CTRL &= ~(1<<EN);
	delay_us(50);
}
void LCD_comm(char ch)
{
	LCD_INST=flip_bits(ch); //upper nibble 명령어 쓰기
	LCD_CTRL &= ~(1<<RS);
	LCD_CTRL |= 1<<EN;
	delay_us(1);
	LCD_CTRL &= ~(1<<EN);
	delay_us(5);

	LCD_INST=flip_bits(ch<<4); //lower nibble 명령어 쓰기
	LCD_CTRL &= ~(1<<RS);
	LCD_CTRL |= 1<<EN;
	delay_us(1);
	LCD_CTRL &= ~(1<<EN);
	delay_ms(5);	
}
void LCD_CHAR(char c) // 한문자 출력 함수
{
	delay_ms(1);
	LCD_data(c); // DDRAM으로 데이터 전달
}
void LCD_STR(char *str) // 위의 문자열을 한문자씩 출력함수로 전달 ,출력해줄 문자열을 받음
{
	while(*str)
	LCD_CHAR(*str++);
}
void LCD_pos(char col, char row) // LCD 포지션 설정
{
	LCD_comm(0x80|(col+row*0x40)); //문자 처음 출력해줄 위치 설정
}
void LCD_clear(void) // 화면 클리어
{
	LCD_comm(1);
}
void LCD_init(void) // LCD 초기화
{
	LCD_comm(0x20); //4bit 초기화
	delay_ms(5);
	LCD_comm(0x28); //데이터 4비트 사용, 5X7도트 , LCD2열로 사용(6) 0010 1000
	delay_ms(5);
	LCD_comm(0x0C); //Display ON/OFF
	delay_ms(5);
	LCD_comm(0x06); //주소 +1 , 커서를 우측으로 이동 (3)
	delay_ms(5);
	LCD_clear();
}
int main(void)
{
	char str[20]="LCD test..      ";
	DDRA=0xF0;
	DDRC |= (1<<RS)|(1<<EN); // PC0~1까지 출력으로 사용
	LCD_init(); //LCD 초기화
	LCD_init(); //LCD 초기화
	LCD_pos(0,0);
	sprintf(str,"Hello");
	LCD_STR(str);
	LCD_pos(0,1);
	sprintf(str,"World");
	LCD_STR(str);
	while(1);
}


