.nolist
.include "m128def.inc"			; ATmega128 definition file
.list

.def	AL		= r16		; can use immediate addressing
.def	AH		= r17
.def	BL		= r18
.def	BH		= r19
.def	CL		= r20
.def	CH		= r21
.def	DL		= r22
.def	DH		= r23

.def	int_counter = r24

;====================================================================
;	Main Program
;====================================================================
.cseg
.org	0x0000
		JMP		RESET					; power-on reset entry point

.org	0x0018
		JMP		TIMER1_COMPA		; interrupt vector OC1A

RESET:	LDI		AH,high(RAMEND)		; initialize SP
		LDI		AL,low(RAMEND)
		OUT		SPH,AH
		OUT		SPL,AL

;------------------------------------------------
;	Initialize Timer/Counter1 CTC Mode
;------------------------------------------------

		LDI		R16, 0xF0		; initialize PORTD4~7 = output
		OUT		DDRD, R16
		OUT		PORTD, R16

		LDI		AL,0b00000000			; CTC mode(4), don't output OC1A
		OUT		TCCR1A,AL
		LDI		AL,0b00001100			; 16MHz/256/(1+624) = 100Hz
		OUT		TCCR1B,AL
		LDI		AL,0b00000000
		STS		TCCR1C,AL
		LDI		AL,high(624)
		OUT		OCR1AH,AL
		LDI		AL,low(624)
		OUT		OCR1AL,AL
		LDI		AL,0x00					; clear Timer/Counter1
		OUT		TCNT1H,AL
		OUT		TCNT1L,AL

;------------------------------------------------
;	Initialize OC1A Interrupt
;------------------------------------------------
		LDI		AL,0b00010000			; enable Timer/Counter1 OC1A interrupt
		OUT		TIMSK,AL
		LDI		AL,0b00000000			; clear all interrupt flags
		OUT		TIFR,AL
		SEI								; global interrupt enable

LOOP:	RJMP	LOOP					; wait interrupt

;====================================================================
;	Interrupt Service Routine of OC1A
;====================================================================
TIMER1_COMPA:
		PUSH	AL						; store registers
		PUSH	AH
		IN		AL,SREG
		PUSH	AL

		INC		int_counter
		CPI		int_counter, 50
		BRNE	SKIP
		LDI		int_counter,0

		IN		AL,PORTD				; toggle LED1
		LDI		AH,0b11110000
		EOR		AL,AH
		OUT		PORTD,AL
SKIP:
		POP		AL						; restore registers
		OUT		SREG,AL
		POP		AH
		POP		AL
		RETI

