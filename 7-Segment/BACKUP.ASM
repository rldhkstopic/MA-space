.INCLUDE "m128def.inc"

.DSEG

	.DEF POS = R25
	.DEF CNT = R24

	.MACRO BITS		
		ROR		@0
	.ENDMACRO


	.MACRO DISPLAY
		PUSH R16
		MOV	R16, @0
		OUT	PORTE, R16
		MOV	R16, @1
		STS	PORTF, R16
		POP R16
	.ENDMACRO

	.MACRO DISPLAY_SHIFT
			BITS	@0
			DISPLAY @0, @1
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

		LDI		CNT, 0
		LDI		R21, 0		
		LDI		R22, 0	

    LOOP:		
		CALL	DIGITS_TWO

		INC		CNT
		CPI		CNT, 60			; IF. CNT is 60
		BRNE	SKIP

		LDI		CNT, 0			; CNT = 0
		INC		R21				; R21 + 1

		CPI		R21, 6			; IF. R21 is 60
		BRNE	SKIP		

		LDI		R21, 0

		INC		R22
		CPI		R22, 6
		BRNE	SKIP

		SKIP:
			CALL	D100MS
			JMP		LOOP		

		DIGITS_TWO:
			PUSH	R16			; TEMP
			PUSH	R17			; ONES_DIGIT
			PUSH	R20			; TENS_DIGIT

			MOV		R17, CNT
			LDI		R20, 0
			LDI		R16, 10

		REPEAT:
			SUB		R17, R16
			BRMI	MINUS		
			INC		R20			

			JMP		REPEAT

		MINUS:
			ADD		R17, R16
			LDI		POS, 0xDF

			DISPLAY	POS, R17, R20
			DISPLAY_SHIFT POS, R21
			DISPLAY_SHIFT POS, R22

			POP		R20
			POP		R17			
			POP		R16

			RET

		
		


	;------------------------------------------------
	;	Delay Subroutine
	;------------------------------------------------
	D500MS: RCALL	D100MS		; delay 500ms
			RCALL	D200MS
			RCALL	D200MS
			RET


	D50MS:  LDI	R18,50
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