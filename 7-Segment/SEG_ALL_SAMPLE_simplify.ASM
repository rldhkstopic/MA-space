.INCLUDE "m128def.inc"

.DSEG
	.DEF POS = R17

	.MACRO BITS
		ROL @0   ; Rotate left through carry (effectively left shift)
	.ENDMACRO

	.MACRO DISPLAY
		MOV	R16, @0
		OUT	PORTE, R16
		LDI	R16, @1
		STS	PORTF, R16
	.ENDMACRO

.CSEG
    .ORG    0x0000
        LDI		R16, LOW(RAMEND)
        OUT		SPL, R16
        LDI		R16, HIGH(RAMEND)
        OUT		SPH, R16

        LDI		R16, 0x0F
        STS		DDRF, R16
        LDI		R16, 0xFF
        OUT		DDRE, R16

    LOOP:
		CALL D100MS
		LDI POS, 0xFE

		DISPLAY POS, 1

		BITS POS 
		DISPLAY POS, 2

		BITS POS 
		DISPLAY POS, 3

		BITS POS 
		DISPLAY POS, 4

		BITS POS 
		DISPLAY POS, 5

		BITS POS 
		DISPLAY POS, 6
		RJMP LOOP

	;------------------------------------------------
	;	Delay Subroutine
	;------------------------------------------------
	D500MS: RCALL	D100MS		; delay 500ms
			RCALL	D200MS
			RCALL	D200MS
			RET

	D5MS:   LDI		R18,5
			RJMP	BASE1MS



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

	D1US:	LDI		R19, 1
			RCALL	BASE1US
			RET
	D20US:	LDI		R19, 20
			RCALL	BASE1US
			RET
	D50US:  LDI		R19, 50
			RCALL	BASE1US
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