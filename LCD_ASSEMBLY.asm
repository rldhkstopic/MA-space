.INCLUDE "m128def.inc"

.DSEG;  

    .EQU F_CPU = 16000000
    .EQU LCD_INST = 0x8000
    .EQU LCD_DATA = 0x8002

    .DEF charData = R16
    .DEF COL = R17
    .DEF ROW = R18

    .DEF RegCnt = R23
    .DEF xRegL = R24
    .DEF xRegH = R25

    .DEF strPtr = R26
    .DEF strIndex = R27

    .MACRO _delay ; 0~254
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_S

        POP R23
        POP R24
        POP R25
    .ENDMACRO

    .MACRO _delay_ms ; 0~254 ms
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_MS

        POP R23
        POP R24
        POP R25
    .ENDMACRO

    .MACRO _delay_us ; 0~254 us
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_US

        POP R23
        POP R24
        POP R25
	.ENDMACRO

.CSEG
.ORG 0x0000
    RJMP LOOP

.ORG 0x0046	
	upperStr: .db "Hello", 0x00
	lowerStr: .db "World", 0x00
	

LOOP:
    LDI R16, LOW(RAMEND)
    OUT SPL, R16
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16

    LDI charData, 0x80
    OUT MCUCR, charData

    CALL LCD_init

    LDI strPtr, LOW(upperStr)
    LDI strIndex, HIGH(upperStr)
    LDI COL, 0
    LDI ROW, 0
    CALL LCD_pos
    CALL LCD_STR

    LDI strPtr, LOW(lowerStr)
    LDI strIndex, HIGH(lowerStr)
    LDI COL, 0
    LDI ROW, 1
    CALL LCD_pos
    CALL LCD_STR

LOOP_MAIN:
    RJMP LOOP_MAIN

LCD_datas:
    STS LCD_DATA, charData
    _delay_us 50

LCD_comm:
    STS LCD_INST, charData
    _delay_ms 5
    RET

LCD_CHAR:
    CALL LCD_datas
    RET
LCD_STR:
    LD charData, Z+
    CPI charData, 0
    BREQ LCD_STR_end
    CALL LCD_CHAR
    RJMP LCD_STR
LCD_STR_end:asd
    RET

LCD_pos:
    LDI charData, 0x80
    ADD charData, COL
    
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    
    ADD charData, ROW
    CALL LCD_comm
    RET

LCD_clear:
    LDI charData, 1
    CALL LCD_comm
    RET

LCD_init:
    LDI charData, 0x38
    CALL LCD_comm
    LDI charData, 0x0C
    CALL LCD_comm
    LDI charData, 0x06

    CALL LCD_comm
    CALL LCD_clear
    RET



; ----------------------------------------.INCLUDE "m128def.inc"

.DSEG
    .EQU F_CPU = 16000000
    .EQU LCD_INST = 0x8000
    .EQU LCD_DATA = 0x8002

    .DEF charData = R16
    .DEF COL = R17
    .DEF ROW = R18

    .DEF RegCnt = R23
    .DEF xRegL = R24
    .DEF xRegH = R25

    .DEF strPtr = R26
    .DEF strIndex = R27

    .MACRO _delay ; 0~254
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_S

        POP R23
        POP R24
        POP R25
    .ENDMACRO

    .MACRO _delay_ms ; 0~254 ms
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_MS

        POP R23
        POP R24
        POP R25
    .ENDMACRO

    .MACRO _delay_us ; 0~254 us
        PUSH R23
        PUSH R24
        PUSH R25

        LDI RegCnt, @0
        CALL DELAY_US

        POP R23
        POP R24
        POP R25
	.ENDMACRO

.CSEG
.ORG 0x0000
    RJMP LOOP

.ORG 0x0046	
	upperStr: .db "Hello", 0x00
	lowerStr: .db "World", 0x00
	

LOOP:
    LDI R16, LOW(RAMEND)
    OUT SPL, R16
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16

    LDI charData, 0x80
    OUT MCUCR, charData

    CALL LCD_init

    LDI strPtr, LOW(upperStr)
    LDI strIndex, HIGH(upperStr)
    LDI COL, 0
    LDI ROW, 0
    CALL LCD_pos
    CALL LCD_STR

    LDI strPtr, LOW(lowerStr)
    LDI strIndex, HIGH(lowerStr)
    LDI COL, 0
    LDI ROW, 1
    CALL LCD_pos
    CALL LCD_STR

LOOP_MAIN:
    RJMP LOOP_MAIN

LCD_datas:
    STS LCD_DATA, charData
    _delay_us 50

LCD_comm:
    STS LCD_INST, charData
    _delay_ms 5
    RET

LCD_CHAR:
    CALL LCD_datas
    RET
LCD_STR:
    LD charData, Z+
    CPI charData, 0
    BREQ LCD_STR_end
    CALL LCD_CHAR
    RJMP LCD_STR
LCD_STR_end:
    RET

LCD_pos:
    LDI charData, 0x80
    ADD charData, COL
    
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    LSL ROW
    
    ADD charData, ROW
    CALL LCD_comm
    RET

LCD_clear:
    LDI charData, 1
    CALL LCD_comm
    RET

LCD_init:
    LDI charData, 0x38
    CALL LCD_comm
    LDI charData, 0x0C
    CALL LCD_comm
    LDI charData, 0x06

    CALL LCD_comm
    CALL LCD_clear
    RET



; ------------------------------------------;


DELAY_S:    
    LDI xRegL, LOW(F_CPU/4)
    LDI xRegH, HIGH(F_CPU/4)

DELAY_S_LOOP:
    SBIW xRegL, 1
    BRNE DELAY_S_LOOP

	DEC RegCnt
	BRNE DELAY_S
    RET

DELAY_MS:    
    LDI xRegL, LOW(F_CPU/4000)
    LDI xRegH, HIGH(F_CPU/4000)

DELAY_MS_LOOP:
    SBIW xRegL, 1
    BRNE DELAY_MS_LOOP

	DEC RegCnt
	BRNE DELAY_MS
    RET

DELAY_US:
    LDI xRegL, LOW((F_CPU / 4000000))
    LDI xRegH, HIGH((F_CPU / 4000000))

DELAY_US_LOOP:
    SBIW xRegL, 1  
    BRNE DELAY_US_LOOP

	DEC RegCnt
	BRNE DELAY_US
    RET
--;


DELAY_S:    
    LDI xRegL, LOW(F_CPU/4)
    LDI xRegH, HIGH(F_CPU/4)

DELAY_S_LOOP:
    SBIW xRegL, 1
    BRNE DELAY_S_LOOP

	DEC RegCnt
	BRNE DELAY_S
    RET

DELAY_MS:    
    LDI xRegL, LOW(F_CPU/4000)
    LDI xRegH, HIGH(F_CPU/4000)

DELAY_MS_LOOP:
    SBIW xRegL, 1
    BRNE DELAY_MS_LOOP

	DEC RegCnt
	BRNE DELAY_MS
    RET

DELAY_US:
    LDI xRegL, LOW((F_CPU / 4000000))
    LDI xRegH, HIGH((F_CPU / 4000000))

DELAY_US_LOOP:
    SBIW xRegL, 1  
    BRNE DELAY_US_LOOP

	DEC RegCnt
	BRNE DELAY_US
    RET
