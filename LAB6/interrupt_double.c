#include <avr/io.h>
#include <avr/interrupt.h>

volatile	int req_INT0=1;
volatile	char rising0;

ISR(INT0_vect)
{
	req_INT0 = 0;
	EIMSK &= 0xFE; /* disable INT0 */
	if (rising0 == 1)
	{
		EICRA &= ~(0x01<<ISC00);
		rising0 = 0;
	}
	else
	{
		EICRA |= 3<<ISC00;
		rising0 = 1;
	}
	EIFR |= 1<<INT0; /* clear INT0 */
	EIMSK |= 1<<INT0; /* enable INT0 */
}

int main(void)
{
	DDRA=1<<PA0;

	EIMSK |=1<<INT0;
	EICRA=3<<ISC00;
	PORTD |= 1<<PD0;
	sei();
	rising0=1;
	while(1){
		if (req_INT0 == 0){
			PORTA ^= 1<<PA0;
			req_INT0 = 1;
		}
	}
}
