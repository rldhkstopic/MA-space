#include <avr/io.h>

#define GET_NOW (PIND & 1 <<PD0 ? 1:0)

int main(void)
{
	int now,prev;

	DDRA=1<<PA0;
	PORTD |= 1<<PD0;

	while(1){
		for(prev=now=GET_NOW ; !(now==1 && prev==0); now=GET_NOW)
			prev=now;

		PORTA ^=1<<PA0;
	}
return 0;
}
