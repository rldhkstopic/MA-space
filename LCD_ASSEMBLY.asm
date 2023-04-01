.INCLUDE "m128def.inc"

.DSEG;  

    .EQU F_CPU = 16000000 ; Define clock speed
    .EQU LCD_INST = 0x8000 ; Set instruction address
    .EQU LCD_DATA = 0x8002 ; Set data address

    .DEF charData = R16 ; Define charData register    
    .DEF COL = R17 ; Define column register
    .DEF ROW = R18 ; Define row register 
    
    .DEF RegCnt = R23 ; Define count register
    .DEF xRegL = R24 ; Define x register low
    .DEF xRegH = R25 ; Define x register high

    .DEF strPtr = R26 ; Define string pointer
    .DEF strIndex = R27 ; Define string index

    .MACRO _delay ; 0~254
        PUSH R23 ; Push RegCnt to the stack
        PUSH R24 ; Push xRegL to the stack
        PUSH R25 ; Push xRegH to the stack

        LDI RegCnt, @0 ; Load delay value to RegCnt
        CALL DELAY_S ; Call delay subroutine

        POP R23 ; Pop RegCnt from the stack
        POP R24 ; Pop xRegL from the stack
        POP R25 ; Pop xRegH from the stack
    .ENDMACRO

    .MACRO _delay_ms ; 0~254 ms
        PUSH R23 ; Push RegCnt to the stack
        PUSH R24 ; Push xRegL to the stack
        PUSH R25 ; Push xRegH to the stack

        LDI RegCnt, @0 ; Load delay value to RegCnt
        CALL DELAY_MS ; Call delay subroutine

        POP R23 ; Pop RegCnt from the stack
        POP R24 ; Pop xRegL from the stack
        POP R25 ; Pop xRegH from the stack
    .ENDMACRO

    .MACRO _delay_us ; 0~254 us
        PUSH R23 ; Push RegCnt to the stack
        PUSH R24 ; Push xRegL to the stack
        PUSH R25 ; Push xRegH to the stack

        LDI RegCnt, @0 ; Load delay value to RegCnt
        CALL DELAY_US ; Call delay subroutine

        POP R23 ; Pop RegCnt from the stack
        POP R24 ; Pop xRegL from the stack
        POP R25 ; Pop xRegH from the stack
    .ENDMACRO

.CSEG
.ORG 0x0000
    RJMP LOOP ; Run main program loop

.ORG 0x0046	
    upperStr: .db "Hello", 0x00 ; Create upper string
    lowerStr: .db "World", 0x00 ; Create lower string
    

LOOP:
    LDI R16, LOW(RAMEND) ; Load lower address of RAM
    OUT SPL, R16 ; Store it in SPL register
    LDI R16, HIGH(RAMEND) ; Load higher address of RAM
    OUT SPH, R16 ; Store it in SPH register

    LDI R16, 0x80 ; Move address to charData register
    OUT MCUCR, R16

    CALL LCD_init ; Initialize LCD

    LDI strPtr, LOW(upperStr) ; Load upper string pointer
    LDI strIndex, HIGH(upperStr) ; Load upper string index
    LDI COL, 0 ; Set column location
    LDI ROW, 0 ; Set row location
    CALL LCD_pos ; Set cursor position
    CALL LCD_STR ; Send upper string to the display

    LDI strPtr, LOW(lowerStr) ; Load lower string pointer
    LDI strIndex, HIGH(lowerStr) ; Load lower string index
    LDI COL, 0 ; Set column location
    LDI ROW, 1 ; Set row location
    CALL LCD_pos ; Set cursor position
    CALL LCD_STR ; Send lower string to the display

LOOP_MAIN:
    RJMP LOOP_MAIN ; Set infinite loop

LCD_datas:
    STS LCD_DATA, charData ; Store charData in LCD_DATA
    CALL D50US  ; Delay for 50 microseconds

LCD_comm:
    STS LCD_INST, charData ; Store charData in LCD_INST
    CALL D5MS ; Delay for 5 milliseconds
    RET ; Return from subroutine

LCD_CHAR:
    CALL LCD_datas ; Send data to LCD
    RET ; Return from subroutine

LCD_STR:
    LD charData, Z+ ; Load data from string
    CPI charData, 0 ; Compare data with null
    BREQ LCD_STR_end ; If data is null, end subroutine
    CALL LCD_CHAR ; Send character to the display
    RJMP LCD_STR ; Continue with the next character

LCD_STR_end:
    RET ; Return from subroutine

LCD_pos:
    PUSH R1 ; Push R1 to the stack
    PUSH R2 ; Push R2 to the stack
    MOV R2, R24 ; Move column location to R2
    MOV R1, R22 ; Move row location to R1
    LSL R1 ; Double R1
    LSL R1 ; Double R1
    LSL R1 ; Double R1
    LSL R1 ; Double R1
    LSL R1 ; Double R1
    OR R2, R1 ; Combine R1 and R2
    CALL LCD_comm ; Send command to the display
    POP R2 ; Pop R2 from the stack
    POP R1 ; Pop R1 from the stack
    RET ; Return from subroutine

LCD_clear:
    LDI charData, 1 ; Move clear command to charData
    CALL LCD_comm ; Send clear command to the display
    RET ; Return from subroutine

LCD_init:
    LDI charData, 0x38 ; Send 8-bit mode command
    CALL LCD_comm ; Send command to the display
    
    LDI charData, 0x0C ; Send display on command
    CALL LCD_comm ; Send command to the display

    LDI charData, 0x06 ; Set entry mode command
    CALL LCD_comm ; Send command to the display

    CALL LCD_clear ; Clear the display
    RET ; Return from subroutine
    
    ; ------------------------------------------;


;------------------------------------------------
;	Delay Subroutine
;------------------------------------------------
D500MS: RCALL	D100MS		; delay 500ms
		RCALL	D200MS
		RCALL	D200MS
		RET

D5MS:   RCALL BASE1MS
        RCALL BASE1MS
        RCALL BASE1MS
        RCALL BASE1MS
        RCALL BASE1MS
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