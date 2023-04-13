.nolist
.INCLUDE "m128def.inc"
.LIST

.DSEG
    .EQU F_CPU = 16000000
    .EQU LCD_INST_PTR = 0x8000
    .EQU LCD_DATA_PTR = 0x8002

    .DEF CHE = R16
    .DEF COL = R17
    .DEF ROW = R18
	.DEF CNT = R21

    .DEF str = R26
    .DEF strIndex = R27

	.MACRO LCD_CHARS
		LDI CHE, @0
		CALL LCD_CHAR
	.ENDMACRO

	.MACRO LCD_POS
		LDI COL, @0
		LDI ROW, @1
		CALL LCD_CURSOR
	.ENDMACRO

	.MACRO LCD_COMM
        STS LCD_INST_PTR, @0
        CALL D5MS
	.ENDMACRO
		

.CSEG
    .ORG 0x0000
        RJMP LOOP

    LOOP: 
        LDI R16, LOW(RAMEND)
        OUT SPL, R16
        LDI R16, HIGH(RAMEND)
        OUT SPH, R16

        LDI R16, 0x80   
        OUT MCUCR, R16 

        CALL LCD_INIT

		LDI CNT, 0x30	

		LCD_POS 5,0
		LCD_CHARS 0X30

		LCD_POS 6,0
		LCD_CHARS 0X30

		LCD_POS 7,0
		LCD_CHARS 0X30

    INFINITE:
		INC CNT
		LCD_POS 7,0
		STS LCD_DATA_PTR, CNT

		CPI CNT, 0x39
		BRNE SKIP
		
		LDI CNT, 0x30   		
	
	SKIP:
		CALL D100MS
		JMP INFINITE


    LCD_INIT:
		PUSH R16
        LDI R16, 0x38
        LCD_COMM R16   ; LCD_comm(0x38)
        LDI R16, 0x0C
        LCD_COMM R16   ; LCD_comm(0x0C)
        LDI R16, 0x06
        LCD_COMM R16   ; LCD_comm(0x06)        
        LDI R16, 0x01
        LCD_COMM R16   ; LCD_clear() : LCD_comm(1)
		POP R16
        RET

	LCD_DATAIN:
        STS LCD_DATA_PTR, CHE
        CALL D50US
        RET

    LCD_CHAR:
        STS LCD_DATA_PTR, CHE
        CALL D50US
        RET
    
    LCD_CURSOR: 			
        PUSH R16   
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
        LCD_COMM R17    ; 
        
        POP R18      
        POP R17         
        POP R16         

        RET             ; return. 



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