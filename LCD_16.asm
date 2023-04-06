.NOLIST
.INCLUDE "m128def.inc"
.LIST

.DSEG
    .EQU F_CPU = 16000000
		


	.DEF CH = R16
    .DEF COL = R17
    .DEF ROW = R18	

	.MACRO LCD_CHAR
		CALL D200US
		MOV CH, @0
		CALL LCD_DATA
	.ENDMACRO

	.MACRO LCD_POS
		MOV COL, @0
		LDI ROW, @1
		CALL LCD_CURSOR
	.ENDMACRO
	
	.MACRO LCD_DISPLAY
		PUSH R16
		.SET INIT_COL = @1
		.SET INIT_ROW = @2	; 0~1 사이
		.SET OFFSET = @3
	
		LDI ZL, LOW(@0)
		LDI ZH, HIGH(@0)

		LDI R16, OFFSET
		ADD ZL, R16
		POP R16

		CALL LCD_STR 
	.ENDMACRO

.CSEG
    .ORG 0x0000
        RJMP LOOP	
	
	uSTR: .DB "HELLO ", "WORLD", 0x00


    LOOP: 
        LDI R16, LOW(RAMEND)
        OUT SPL, R16
		LDI R16, HIGH(RAMEND)
        OUT SPH, R16

		LDI R16, 0xF0
		OUT DDRA, R16
				
		LDI R16, 0x03
		OUT DDRC, R16
		
        CALL LCD_INIT

		
		LCD_DISPLAY uSTR, 5, 0, 0

    INFINITE:	
		JMP INFINITE


    LCD_INIT:
        LDI CH, 0x20
        CALL LCD_COMM   ; LCD_comm(0x20)
		CALL D5MS
        LDI CH, 0x28
        CALL LCD_COMM   ; LCD_comm(0X28)
		CALL D5MS
        LDI CH, 0x0C
        CALL LCD_COMM   ; LCD_comm(0x0C)  
		CALL D5MS    
		LDI CH, 0x06
        CALL LCD_COMM   ; LCD_comm(0x06) 
		CALL D5MS    
        LDI CH, 0x01
        CALL LCD_COMM   ; LCD_clear() : LCD_comm(1)
        RET

	LCD_COMM:
		PUSH R17
		LDI R17, PORTC

		RCALL FLIP_BITS

		OUT PORTA, R20	; flip_bits(ch)

		ANDI R17, 0xFD	;
		OUT PORTC, R17	; PORTC &= ~(0x02)
		ORI R17, 0x01	
		OUT PORTC, R17	; PORTC |= 0x01
		CALL D1US
		ANDI R17, 0xFE
		OUT PORTC, R17	; PORTC &= ~(0x01)
		CALL D20US

		LSL CH
		LSL CH
		LSL CH
		LSL CH
		RCALL FLIP_BITS

		OUT PORTA, R20	; flip_bits(ch<<4)
		
		ANDI R17, 0xFD	;
		OUT PORTC, R17	; PORTC &= ~(0x02)
		ORI R17, 0x01	
		OUT PORTC, R17	; PORTC |= 0x01
		CALL D1US
		ANDI R17, 0xFE
		OUT PORTC, R17	; PORTC &= ~(0x01)
		CALL D5MS
		
		POP R17

		RET
	    
	LCD_DATA:
		PUSH R17
		PUSH R18

		LDI R17, PORTC

		RCALL FLIP_BITS 

		OUT PORTA, R20	; flip_bits(ch)

		ORI R17, 0x02	
		OUT PORTC, R17	; PORTC |= 0x02
		ORI R17, 0x01	
		OUT PORTC, R17	; PORTC |= 0x01
		CALL D1US
		ANDI R17, 0xFE
		OUT PORTC, R17	; PORTC &= ~(0x01)
		CALL D20US

		LSL CH
		LSL CH
		LSL CH
		LSL CH
		RCALL FLIP_BITS 
		
		OUT PORTA, R20	; flip_bits(ch<<4)

		ORI R17, 0x02	
		OUT PORTC, R17	; PORTC |= 0x02		
		ORI R17, 0x01	
		OUT PORTC, R17	; PORTC |= 0x01
		CALL D1US
		ANDI R17, 0xFE
		OUT PORTC, R17	; PORTC &= ~(0x01)
		CALL D50US
		
		POP R18
		POP R17

		RET

    LCD_CURSOR: 	
        PUSH R17    
        PUSH R18  

		MOV R17, COL ; move COL to R17
		MOV R18, ROW ; move ROW to R18

		LSL R18
		LSL R18
		LSL R18
		LSL R18
		LSL R18
		LSL R18

        ADD R17, R18    ; R17 <- COL + ROW * 0x40
        ORI R17, 0x80   ; R17 <- 0x80|(COL + ROW * 0x40)
		MOV CH, R17
        RCALL LCD_COMM	; 
        
        POP R18      
        POP R17           

        RET  

;------------------------------------------------
;	String Subroutine
;------------------------------------------------


	LCD_STR:
		PUSH R22 
		PUSH R21	
		LDI R22, 0
		LDI R21, INIT_COL

	STR_LOOP:
		LPM R22, Z+		 ; Load the character pointed by Z (strPtr)
		TST R22			 ; Compare R20 with 0 (end of string)
		BREQ STR_END	 ; If R22 == 0, branch to STR_END				

		INC R21
		CPI R21, INIT_COL+1
		BREQ STR_LOOP

		MOV R1, R21
		DEC R1
		DEC R1
		LCD_POS R1, INIT_ROW
		LCD_CHAR R22	

		RJMP STR_LOOP	
	

	STR_END:
		POP R21 
		POP R22 
		RET 
     

;------------------------------------------------
;	flip_bits Subroutine
;------------------------------------------------
	FLIP_BITS:				; char flip_bits(char ch)
		PUSH R17 
		PUSH R18
		PUSH R19

		LDI R19, 0x00		; char return_ch = 0;

		LDI R17, 0x10		; Load 0x10 into R17
		MOV R18, CH			; Copy R16 (ch) into R16
		LSR R18				; Shift right by 3
		LSR R18
		LSR R18
		AND R18, R17   
		MOV R19, R18		; return_ch = (ch >> 3) & 0x10

		LDI R17, 0x20		; Load 0x20 into R17
		MOV R18, CH			; Copy R16 (ch) into R18
		LSR R18				; Shift right by 1
		AND R18, R17   
		OR R19, R18			; return_ch = return_ch | (ch >> 1) & 0x20

		LDI R17, 0x40		; Load 0x40 into R17
		MOV R18, CH			; Copy R16 (ch) into R18
		LSL R18				; Shift left by 1
		AND R18, R17 
		OR R19, R18			; return_ch = return_ch | (ch << 1) & 0x40

		LDI R17, 0x80		; Load 0x80 into R17
		MOV R18, CH			; Copy R16 (ch) into R18
		LSL R18				; Shift left by 3
		LSL R18
		LSL R18
		AND R18, R17    
		OR R19, R18			; return_ch = return_ch | (ch << 3) & 0x80

		MOV R20, R19		; return return_ch

		POP R19
		POP R18
		POP R17		 
		RET			

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