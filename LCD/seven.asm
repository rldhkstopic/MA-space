;	Date: 2016.10.9
;   Programmer: DJ Lim
;	Seven segments display example

.nolist
.include "m128def.inc"			
.list

.def	ones_digit = r20
.def	tens_digit = r21
.def	temp	= r22
.def	counter = r23

.cseg
.org	0x0000
		LDI		R17,high(RAMEND)	; initialize SP
		LDI		R16,low(RAMEND)
		OUT		SPH,R17
		OUT		SPL,R16

;------------------------------------------------
;	Port Initialization
;------------------------------------------------
		LDI		R16, 0xF0		; initialize PORTD4~7 = output
		OUT		DDRD, R16
		LDI		R16, 0x0F
		STS		DDRF, R16
		LDI		R16, 0xFF
		OUT		DDRE, R16

;------------------------------------------------
;	Main Loop
;------------------------------------------------
		LDI		counter, 0
LOOP:	
		MOV		ones_digit, counter
		CALL	DISPLAY_TWO_DIGITS
		INC		counter
		CPI		counter, 100
		BRNE	SKIP
		LDI		counter, 0
SKIP:	CALL	D100MS
		JMP		LOOP

;------------------------------------------------
;	Display Two Digits Subroutine
;------------------------------------------------

DISPLAY_TWO_DIGITS:
		CALL	DIGITS
		LDI		R17,0xEF
		OUT		PORTE, R17
		STS		PORTF, tens_digit
		LDI		R17,0xDF
		OUT		PORTE, R17
		STS		PORTF, ones_digit
		RET

DIGITS:
		push 	temp
		ldi		tens_digit,0
		ldi		temp,10
REPEAT:	sub		ones_digit, temp	
		brmi	MINUS
		inc		tens_digit
		rjmp	REPEAT
MINUS: 	add		ones_digit,temp
		pop 	temp
		ret

;------------------------------------------------
;	Delay Subroutine
;------------------------------------------------
D500MS: RCALL	D100MS		; delay 500ms
		RCALL	D200MS
		RCALL	D200MS
		RET

D100MS: LDI		R18,100
		RJMP	BASE1MS
D200MS: LDI		R18,200
BASE1MS:RCALL	D200US		; 200 us
		RCALL	D200US		; 200 us
		RCALL	D200US		; 200 us
		RCALL	D200US		; 200 us
		RCALL	D200US		; 200 us
		DEC		R18
		BRNE	BASE1MS		; (total = 1 ms)
		RET

D200US: LDI		R19,200			; delay 200us
BASE1US:NOP					; 1
		PUSH	R19			; 2
		POP		R19			; 2
		PUSH	R19			; 2
		POP		R19			; 2
		PUSH	R19			; 2
		POP		R19			; 2
		DEC		R19			; 1
		BRNE	BASE1US		; 2 (total 16 cycles = 1 us)
		RET
