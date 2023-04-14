#include <avr/io.h>
#include <avr/interrupt.h>

volatile	int req_INT0=1;

ISR(INT0_vect)
{
	req_INT0 = 0;;
}

int main(void)
{

	DDRA=1<<PA0;

	EIMSK |=1<<INT0;
	EICRA=3<<ISC00;
	PORTD |= 1<<PD0;
	sei();

	while(1){
		if (req_INT0 == 0){
			PORTA ^= 1<<PA0;
			req_INT0 = 1;
		}
	}

}
