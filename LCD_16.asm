.nolist
.INCLUDE "m128def.inc"
.LIST

.DSEG
    .EQU F_CPU = 16000000
    .EQU LCD_INST_PTR = 0x8000
    .EQU LCD_DATA_PTR = 0x8002

    .EQU RS = 0x01
    .EQU EN = 0x00

    .DEF CHE = R16
    .DEF COL = R17
    .DEF ROW = R18

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
        
        LDI R16, 0xF0
        OUT DDRA, R16
        

        

        LCD_POS 0, 0
        LCD_CHARS 'L'

		LCD_POS 1, 0
        LCD_CHARS 'O'

		LCD_POS 0, 1
        LCD_CHARS 'V'

		LCD_POS 1, 1
        LCD_CHARS 'E'

    INFINITE:
        RJMP INFINITE    

    LCD_INIT:
		PUSH R16
        LDI R16, 0x20
        LCD_COMM R16   ; LCD_comm(0x20)
        CALL D5MS
        LDI R16, 0x28
        LCD_COMM R16   ; LCD_comm(0x28)
        CALL D5MS
        LDI R16, 0x0C
        LCD_COMM R16   ; LCD_comm(0x0C)    
        CALL D5MS    
        LDI R16, 0x06
        LCD_COMM R16   ; LCD_comm(0x06)   
        CALL D5MS   
        LDI R16, 0x01
        LCD_COMM R16   ; LCD_clear() : LCD_comm(1)
        CALL D5MS
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

    FLIP_BITS:
        

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