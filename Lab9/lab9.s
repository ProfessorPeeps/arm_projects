;------------------------------------------------------------------------
PINSEL0	EQU	0xE002C000
PINSEL1	EQU	0xE002C004
PINSEL2	EQU	0xE002C014

IO0DIR	EQU	0xE0028008
IO1DIR	EQU	0xE0028018

IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

IO0PIN	EQU	0xE0028000
IO1PIN	EQU	0xE0028010

;masks
LCD_DATA	EQU	0x00FF0000	;P1.16 - P1.23	Send info
LCD_RS		EQU	0x01000000		;p1.24	0=CMD	1=CHAR	interpretation
LCD_E		EQU	0x02000000		;p1.25	Crank 1->0 to execute
LCD_RW		EQU	0x00400000		;P0.22
LCD_LIGHT	EQU	0x40000000	;P0.30

SET0_DATA	EQU	0xFF9FFFFF
SET0_RS		EQU 0xFEFFFFFF
SET0_E		EQU 0xFDFFFFFF
SET0_RW		EQU 0xFFBFFFFF

PINSEL1GPIO	EQU	0x30003000	;Mask to set pins 22 and 30 to GPIO
PINSEL2GPIO	EQU	0x00000008	;Mask to set pins 1.16-1.25 to GPIO

IO0DIROUT	EQU	0x40400000
IO1DIROUT	EQU	0x03FF0000



LCDWAKE	EQU	0x300000	;send 3 times
LCDISET	EQU	0x380000
LCD_ON	EQU	0x0C0000
LCDCLR	EQU	0x010000
AUTOR	EQU	0x060000	

;delay values
WAIT_6us	EQU	0x25
WAIT_40us	EQU	0xF1
WAIT_100us	EQU	0x259
WAIT_4ms	EQU	0x6019
WAIT_15ms	EQU	0x00015F91


;------------------------------------------------------------------------
	IMPORT DELAY
	IMPORT LCD_cmd
	GLOBAL	user_code
	AREA mycode,CODE,READONLY
	ENTRY

user_code

LCD_pins

	LDR	r0,=PINSEL1
	LDR	r1,[r0]
	LDR r3, =PINSEL1GPIO
	BIC	r1,r1,r3
	STR	r1,[r0]
	
	LDR	r0,=PINSEL2
	LDR	r1,[r0]
	LDR r3, =PINSEL2GPIO
	BIC	r1,r1,r3
	STR	r1,[r0]
	
	LDR	r0,=IO0DIR
	LDR	r1,[r0]
	LDR r3, =IO0DIROUT
	ORR	r1,r1, r3
	STR	r1,[r0]
	LDR	r0,=IO1DIR
	LDR	r1,[r0]
	LDR r3, =IO1DIROUT
	ORR	r1,r1,r3
	STR	r1,[r0]

		
LCDint
	;LDR	r0,=LCD_E	
	;LDR	r1,=LCD_RS	
	;LDR	r2,=LCD_RW	
	;LDR	r3,=LCD_DATA	
	
	
MORNING_ROUTINE					;STEP 1

	STMFA	SP!, {r0 - r12, LR}
	MRS		r1, CPSR
	
	LDR	R0,=IO0PIN  
	LDR	R1,=IO1PIN
	LDR	R2,[r0]
	LDR	R3,[r1]
	
	LDR	r4,=SET0_RS		;set RS = 0	
	AND	R3,R3,r4
	STR R3,[R1]
	
	
	LDR	r4,=SET0_E	
	AND	R3,R3,r4
	STR R3,[R1]
	
	LDR	r4,=SET0_RW
	AND	R2,R2,R4
	STR	r2,[r0]
	
	LDR r9,=WAIT_15ms
	BL DELAY
	;step 2
	
	LDR	r4,=LCDWAKE	
		BL LCD_cmd
	LDR r9,=WAIT_4ms
	BL DELAY
	
	;step 3
	LDR	r4,=LCDWAKE	
	BL LCD_cmd
	LDR r9,=WAIT_100us
	BL DELAY
	
	;step 4
	LDR	r4,=LCDWAKE	
	BL LCD_cmd
	LDR r9,=WAIT_4ms
	BL DELAY
	
	;step 5
	LDR	r4,=LCDISET	
	BL LCD_cmd
	
	;step 6
	LDR	r4,=LCD_ON	
	BL LCD_cmd
	
	;step 7
	LDR	r4,=LCDCLR	
	BL LCD_cmd
	
	;step 8
	LDR	r4,=AUTOR	
	BL LCD_cmd
	
	;LCDWAKE	EQU	0x300000	;send 3 times
;LCDISET	EQU	0x380000
;LCD_ON	EQU	0x0C0000
;LCDCLR	EQU	0x010000
;AUTOR	EQU	0x060000
	;AND	r4,r4,#0x0	; E = RS = RW = 0, and wait for at least 15ms
	;AND	r5,r5,#0x0
	;AND	r6,r6,#0x0
	;STR	r4,[r0]	;E=RS=RW=0
	;STR	r5,[r1]
	;STR	r6,[r2]

	;LCD_DATA	EQU	0x00FF0000	;P1.16 - P1.23	Send info
	;LCD_RS	EQU	0x01000000		;p1.24	0=CMD	1=CHAR	interpretation
	;LCD_E	EQU	0x02000000		;p1.25	Crank 1->0 to execute
	;LCD_RW	EQU	0x00400000		;P0.22
	;LCD_LIGHT	EQU	0x40000000	;P0.30
	;IO0PIN	EQU	0xE0028000
	;IO1PIN	EQU	0xE0028010
	
	
	
	
	
	
	;BX LR


	END