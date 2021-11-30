	IMPORT user_code
	IMPORT DELAY
;delay value (4 clk cyc / 12e6 Hz)

	GLOBAL LCD_cmd
	AREA mycode,CODE,READONLY

WAIT_6us	EQU	0x25
WAIT_40us	EQU	0xF1
WAIT_100us	EQU	0x259
WAIT_4ms	EQU	0x6019
WAIT_15ms	EQU	0x00015F91


SET0_DATA	EQU	0xFF9FFFFF
SET0_RS		EQU 0xFEFFFFFF
SET0_E		EQU 0xFDFFFFFF
SET0_RW		EQU 0xFFBFFFFF

LCDWAKE	EQU	0x300000	;send 3 times
LCDISET	EQU	0x380000
LCD_ON	EQU	0x0C0000
LCDCLR	EQU	0x010000
AUTOR	EQU	0x060000	

LCD_E		EQU	0x02000000

LCD_cmd

;(1) D[7:0] = command (passed from the calling program).
	LDR	R3,[r1]
	ORR	r3,r4,r3
	STR r3,[R1]

;(2) RS = 0, R/W = 0, and E = 0 ; and wait for at least 6µ??.
	LDR	r4,=SET0_RS		;set RS = 0
	AND	R3,R3,r4
	STR R3,[R1]
		
	LDR	r4,=SET0_E	
	AND	R3,R3,r4
	STR R3,[R1]
	
	LDR	r4,=SET0_RW
	AND	R2,R2,R4
	STR	r2,[r0]
	
	LDR r9,=WAIT_6us
	BL	DELAY
;(3) E = 1 ; and wait for at least 6µ??.
	LDR	r4,=LCD_E	
	ORR	R3,R3,r4
	STR R3,[R1]

	LDR	r9,=WAIT_6us
	BL	DELAY
;(4) E = 0; and wait for at least 40µ??.
	LDR	r4,=SET0_E	
	AND	R3,R3,r4
	STR R3,[R1]

	LDR r9,=WAIT_40us
	BL	DELAY
;CLEANUP
	LDR r4,=SET0_DATA
	AND R3,r3,r4
	STR	R3,[R1]
	BX LR
		END