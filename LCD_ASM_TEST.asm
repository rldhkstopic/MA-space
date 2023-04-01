.nolist
.INCLUDE "m128def.inc"
.LIST

.DSEG
    .EQU F_CPU = 16000000
    .EQU LCD_INST_PTR = 0x8000
    .EQU LCD_DATA_PTR = 0x8002

    .DEF CHD = R20
    .DEF COL = R21
    .DEF ROW = R22

    .DEF str = R26
    .DEF strIndex = R27

.CSEG
    .ORG 0x0000
        RJMP LOOP

    .ORG 0x0046
        uStr : .DB "HELLO", 0x00
        lStr : .DB "WORLD", 0x00

    LOOP: 
        LDI R16, LOW(RAMEND)
        OUT SPL, R16
        LDI R16, HIGH(RAMEND)
        OUT SPH, R16

        LDI R16, 0x80   
        OUT MCUCR, R16          ; 1000 0000

        CALL LCD_INIT

        LDI COL, 0
        LDI ROW, 0
        CALL LCD_POS
        CALL LCD_CHAR

        LDI COL, 0
        LDI ROW, 1
        CALL LCD_POS
        CALL LCD_CHAR

    INFINITE:
        RJMP INFINITE    

    LCD_INIT: ; void
        LDI CHD, 0x38
        CALL LCD_COMM   ; LCD_comm(0x38)
        LDI CHD, 0x0C
        CALL LCD_COMM   ; LCD_comm(0x0C)
        LDI CHD, 0x06
        CALL LCD_COMM   ; LCD_comm(0x06)
        
        LDI CHD, 0x01
        CALL LCD_COMM   ; LCD_clear() : LCD_comm(1)

        RET

	LCD_DATAIN: ; char ch
        CALL LCD_DATA
        CALL D50US
        RET

    LCD_COMM: ; char ch
        CALL LCD_INST
        CALL D5MS
        RET

	LCD_INST:
        PUSH R16
        ;LDI R16, CHD
        STS LCD_INST_PTR, CHD
        POP R16
		RET

    LCD_DATA:
        PUSH R16
        ;LDI R16, CHD
        STS LCD_DATA_PTR, CHD
        POP R16
		RET

    LCD_CHAR:
        LDI CHD, 'L'
        CALL LCD_DATA
        CALL D50US
        RET
    
    LCD_POS:  ; char col, char row
        PUSH R16   
        PUSH R17    
        PUSH R18  
		PUSH R19

        MOV R17, COL    ; move COL to R17
        MOV R18, ROW    ; move ROW to R18
		LDI R19, 0x40

        MUL R18, R19   ; R18 <- ROW * 0x40
        ADD R17, R18    ; R17 <- COL + ROW * 0x40
        ORI R17, 0x80   ; R17 <- 0x80|(COL + ROW * 0x40)

        MOV CHD, R17     ; CH <- R17
        CALL LCD_COMM   ; call LCD_COMM with CH in R16
        
		POP R19
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