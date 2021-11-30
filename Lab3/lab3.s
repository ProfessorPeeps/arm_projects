	GLOBAL	Reset_Handler
VAL1	EQU	0xEF
VAL2	EQU	0xAB
VAL3	EQU	0x33221100
VAL4	EQU	0XFFEEDDCC
ADDR1	EQU	0x40000000
ADDR2	EQU	0x40000004
ADDR3	EQU	0x40000008
ADDR4	EQU	0X4000000C
ADDR5	EQU	0x40000010
ADDR6	EQU	0X40000014	
	AREA	mycode,CODE,READONLY

Reset_Handler	;this label is necessary for Startup to find

; TASK 1

;place 2 values into registers
	LDR R0,=VAL1
	LDR R1,=VAL2	
;move registers to the 2 adresses
	mov R2, #ADDR1
	mov R3, #ADDR2
;store the 2 values at adress	
	STR R0,[R2]
	STR R1,[R3]

; TASK 2

;place 2 values into registers
	LDR R4, =VAL3
	LDR R5, =VAL4	
;move registers to the 2 adresses
	mov R6, #ADDR3
	mov R7, #ADDR4
;store the 2 values at adress	
	STR R4,[R6]
	STR R5,[R7]

; TASK 3
	LDR	R8,TABLE
	MOV R9,#ADDR5
	STR R8, [R9]
	
	ADR R10, TABLE 
	LDR R12, [R10,#4]
	MOV R11,#ADDR6
	STR R12, [R11]
	
; TASK 3 - OPTIMIZED

	;ADR	R0,TABLE
	;MOV R1,#ADDR1
	;STR R0, [R1]
	 
	;LDR R4, [R0,#4]
	;MOV R3,#ADDR2
	;STR R4, [R3]

stop	B	stop	;endless loop to make the program hang

TABLE	DCD	0x12345678, 0xFEDCBA98
	
	END	;assembler directive to indicate the end of code
