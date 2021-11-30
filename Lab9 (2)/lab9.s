;------------------------------------------------------------------------
;GPIO addresses for Port0 and Port1
PINSEL0	EQU	0xE002C000
PINSEL1	EQU	0xE002C004
PINSEL2	EQU	0xE002C014

;GPIO masks
PINSEL1GPIO	EQU	0x30003000	;Mask to set pins 22 and 30 to GPIO
PINSEL2GPIO	EQU	0x00000008	;Mask to set pins 1.16-1.25 to GPIO
	
;Pin direction addresses for Port0 and Port1
IO0DIR	EQU	0xE0028008
IO1DIR	EQU	0xE0028018

;Pin direction masks
IO0DIROUT	EQU	0x40400000	;Mask to set pin direction for Port0
IO1DIROUT	EQU	0x03FF0000	;Mask to set pin direction for Port1

;Set or clear data in pins
IO0SET	EQU	0xE0028004		
IO1SET	EQU	0xE0028014
IO0CLR	EQU	0xE002800C
IO1CLR	EQU	0xE002801C

IO0PIN	EQU	0xE0028000		;contains pin data for Port0
IO1PIN	EQU	0xE0028010		;contains pin data for Port1

;Bit position for LCD pins
LCD_DATA	EQU	0x00FF0000		;P1.16 - P1.23  => data pins D[0:7]
LCD_RS		EQU	0x01000000		;p1.24 			=> register select (0 = cmd, 1 = char)
LCD_E		EQU	0x02000000		;p1.25 			=> enable 
LCD_RW		EQU	0x00400000		;P0.22			=> read / write 
LCD_LIGHT	EQU	0x40000000		;P0.30			=> LCD backlight
	
;negation for IOXCLEAR 
NEG_LIGHT	EQU 0xBFFFFFFF		;negative mask for P0.30
NEG_DATA	EQU 0xFF00FFFF		;negative mask for P1.16 - P.23

;Cursor MASK left most
L1ROW	EQU	0x80
L2ROW	EQU	0xC0
	
;cursor mask right most	
R1ROW	EQU	0x8F
;------------------------------------------------------------------------

	IMPORT DELAY
	GLOBAL lcd_subs
		
	AREA mycode,CODE,READONLY
	ENTRY

;----------------------------------------------------------;
;Task 1: Call subroutines for LCD display initialization   ;
;----------------------------------------------------------;

lcd_subs

	;set up the pins to serve the LCD
	BL LCD_pins
	
	;initialize the LCD (wakeup routine)
	BL LCD_init

;----------------------------------------------------------;
;Task 2: Display two character strings in first and second ;
;        line of the LCD by calling each subroutine. 	   ; 
;----------------------------------------------------------;

TASK2

	;Write strings to LCD
	BL LCD_string

	B EXIT

;----------------------------------------------------------;
;This subroutine will initialize the pins to work as an LCD;
;----------------------------------------------------------;

LCD_pins

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r0, CPSR				;preserve status register
	STMFD	SP!, {r0}

	;Set GPIO for Port0 and Port1
	LDR	r0, =PINSEL1			;read contents of Port 0
	LDR	r1,[r0]
	LDR r3, =PINSEL1GPIO		;read mask for GPIO	
	BIC	r1,r1,r3				;clear P0.22 and P0.30
	STR	r1,[r0]
	
	LDR	r0,=PINSEL2				;read contents of Port 1
	MOV r2, #0
	STR	r2,[r0]

	;Set pin direction for Port0
	LDR	r0,=IO0DIR			;read contents of IODIR
	LDR	r1,[r0]
	LDR r3, =IO0DIROUT
	ORR	r1,r1, r3			;set Port0 pins to output
	STR	r1,[r0]
	
	;Set pin direction for Port1
	LDR	r0,=IO1DIR
	LDR	r1,[r0]
	LDR r3, =IO1DIROUT
	ORR	r1,r1,r3			;set Port1 pins to output
	STR	r1,[r0]
	
	;Turn on the LCD backlight 
	LDR r0,=LCD_LIGHT		;set P0.30
	LDR r1,=IO0SET
	STR r0,[r1]
	
	;Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0
	LDMFD	SP!, {r0 - r12, LR}	
	
	BX LR

;--------------------------------------------------;
;This subroutine will initialize the LCD and wakeup;
;--------------------------------------------------;

LCD_init
	
	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r1, CPSR				;preserve status register
	STMFD	SP!, {r1}			
	
;(1) Set E, RS, RW = 0 and wait for 15 ms	

	;set RS = 0
	LDR r4,=LCD_RS		
	LDR r5,=IO1CLR		;set P1.24 to zero
	STR r4, [r5]
	
	;set E = 0
	LDR r4,=LCD_E		
	LDR r5,=IO1CLR		;set P1.25 to zero
	STR r4, [r5]
	
	;set R/W = 0
	LDR r4, =LCD_RW		
	LDR r5, =IO0CLR		;set P0.22 to zero
	STR r4, [r5]
	
	;Wait for 15 ms
	LDR r0, =2000		;delay in increments of 10 us
	BL DELAY			;15e-3 s / 10e-6 s 

;(2) Send a command to pins D[7:0] and wait for 4.1 ms
	MOV r0, #0x30		
	BL LCD_cmd			;send wakeup command
	LDR r0, =1000		;delay in increments of 10 us
	BL DELAY			;41e-3 s / 10e-6 s
	
;(3) Send a command to pins and wait 100 us	
	MOV r0, #0x30		
	BL LCD_cmd			;send wakeup command
	LDR r0, =20			;delay in increments of 10 us
	BL DELAY			;100e-6 s / 10e-6 s
	
;(4) Send command 0x30 to pins	and wait 4.1 ms
	MOV r0, #0x30		
	BL LCD_cmd			;send wakeup command
	LDR r0, =1000			;delay in increments of 10 us
	BL DELAY			;100e-6 s / 10e-6 s

;(5) Send 0x38 command to LCD
	MOV r0, #0x38		
	BL LCD_cmd			;send function select command
	LDR r0, =410		;delay in increments of 10 us
	BL DELAY			;41e-3 s / 10e-6 s
	
;(6) Send 0x0c command to LCD
	MOV r0, #0x0C		
	BL LCD_cmd			;send LCD display on control command
	LDR r0, =410		;sending command still needs a delay
	BL DELAY			
	
;(7) Send 0x01 command to LCD
	MOV r0, #0x01		
	BL LCD_cmd			;send clear LCD display command	
	LDR r0, =410		
	BL DELAY			
	
;(8) Send 0x06 command to LCD
	MOV r0, #0x06		
	BL LCD_cmd			;send entry mode set command	
	LDR r0, =410		
	BL DELAY			
	
	;**Stack stuff					;ANOTHER METHOD TO RETURN FROM SUBROUTINE
	LDMFD	SP!, {r0}				
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, PC}		;restore registers
	
;--------------------------------------------------;
;This subroutine will send a command to the LCD    ;
;--------------------------------------------------;

LCD_cmd

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r1, CPSR				;preserve status register
	STMFD	SP!, {r1}				

;(1) D[7:0] = command (passed from the calling program).
	
	LDR r2, =IO1PIN		;r2 contains pin data
	
	;shift data 
	LSL r1, r0, #16		;shift command by 16 bits
		
	LDR r4, =LCD_DATA		
	LDR r5,[R2]
	LDR R6,=NEG_DATA
	AND r5, r5, r6
	ORR r3, r1, r5		;mask pins D[0:7] with command data
	STR r3, [r2]		;store command to pin data

;(2) RS = 0, R/W = 0, and E = 0 ; and wait for at least 6탎.

	;set RS = 0
	LDR r4,=LCD_RS		
	LDR r5,=IO1CLR		;set P1.24 to zero
	STR r4, [r5]
	
	;set E = 0
	LDR r4,=LCD_E		
	LDR r5,=IO1CLR		;set P1.25 to zero
	STR r4, [r5]
	
	;set R/W = 0
	LDR r4, =LCD_RW		
	LDR r5, =IO0CLR		;set P0.22 to zero
	STR r4, [r5]
	
	;Wait for 6us
	LDR r0, =6		;delay in increments of 1 us		
	BL DELAY		;6e-6 s / 1e-6 s

;(3)E = 1 ; and wait for at least 6탎.

	;set E = 1
	LDR r4,=LCD_E		
	LDR r5,=IO1SET		;set P1.25 to one
	STR r4, [r5]
	
	;Wait for 6us
	LDR r0, =6		;delay in increments of 1 us		
	BL DELAY		;6e-6 s / 1e-6 s

;(4) E = 0; and wait for at least 40탎.

	;set E = 0
	LDR r4,=LCD_E		
	LDR r5,=IO1CLR		;set P1.25 to zero
	STR r4, [r5]
	
	;Wait for 40us
	LDR r0, =4		;delay in increments of 10 us		
	BL DELAY		;40e-6 s / 10e-6 s
	
	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, LR}		;restore registers
	
	BX LR
	
;--------------------------------------------------;
;This subroutine will send a char to the LCD       ;
;--------------------------------------------------;

LCD_char

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r1, CPSR				;preserve status register
	STMFD	SP!, {r1}				

;(1) D[7:0] = command (passed from the calling program).

	LDR r2, =IO1PIN		;r2 contains pin data
	
	;shift data 
	LSL r1, r0, #16		;shift command by 16 bits
		
	LDR r4, =LCD_DATA		
	LDR r5,[R2]
	LDR R6,=NEG_DATA
	AND r5, r5, r6
	ORR r3, r1, r5		;mask pins D[0:7] with command data
	STR r3, [r2]		;store command to pin data

;(2) RS = 1, R/W = 0, and E = 0 ; and wait for at least 6탎.

	;set RS = 1			;sets to char mode
	LDR r4,=LCD_RS		
	LDR r5,=IO1SET		;set P1.24 to zero
	STR r4, [r5]
	
	;set E = 0
	LDR r4,=LCD_E		
	LDR r5,=IO1CLR		;set P1.25 to zero
	STR r4, [r5]
	
	;set R/W = 0
	LDR r4, =LCD_RW		
	LDR r5, =IO0CLR		;set P0.22 to zero
	STR r4, [r5]
	
	;Wait for 60us
	LDR r0, =6		;delay in increments of 1 us		
	BL DELAY		;6e-6 s / 1e-6 s

;(3)E = 1 ; and wait for at least 6탎.

	;set E = 1
	LDR r4,=LCD_E		
	LDR r5,=IO1SET		;set P1.25 to one
	STR r4, [r5]
	
	;Wait for 60us
	LDR r0, =6		;delay in increments of 1 us		
	BL DELAY		;6e-6 s / 1e-6 s

;(4) E = 0; and wait for at least 40탎.

	;set E = 0
	LDR r4,=LCD_E		
	LDR r5,=IO1CLR		;set P1.25 to zero
	STR r4, [r5]
	
	;Wait for 40us
	LDR r0, =4		;delay in increments of 10 us		
	BL DELAY		;40e-6 s / 10e-6 s
	
	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, LR}		;restore registers
	
	BX LR

;--------------------------------------------------;
;This subroutine will clear the LCD			       ;
;--------------------------------------------------;

LCD_clear

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r0, CPSR				;preserve status register
	STMFD	SP!, {r0}				

	;Call clear command 
	MOV r0, #0x01
	BL LCD_cmd

	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, LR}		;restore registers

	BX LR
	
;--------------------------------------------------;
;This subroutine will send a string to the LCD	   ;
;--------------------------------------------------;

LCD_string

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r0, CPSR				;preserve status register
	STMFD	SP!, {r0}				

;initialize for row 1
;ADDRESS OF LCD AND STRING TABLE

	LDR R1, =L1ROW			;index row 2
	MOV R2, #0				;index for string (character position)	
	ADR R3, test_string1	
	
ROW1
	;Fetch first cursor position 
	MOV r0, r1
	BL LCD_cmd
	
	;Update index after command is called
	ADD  R1, r1, #1		
	
	;Grab char from string
	LDRB r0, [r2, r3]	;fetch current character
	ANDS R0,R0,R0		;check for end of string
	BEQ NEXTROW			;If end of string is reached, move to next row
	BL LCD_char			;call char command
	
	ADD r2, r2, #1		;fetch next character of string
	
	B ROW1

NEXTROW

;initialize for row 2
;ADDRESS OF LCD AND STRING TABLE

	LDR R1, =L2ROW			;index of cursor position
	MOV R2, #0				;index for string (character position)
	ADR R3, test_string2
				
ROW2
	;Fetch first cursor position 
	MOV r0, r1
	BL LCD_cmd
	
	;Update index after command is called
	ADD  R1, r1, #1		
	
	;Same process as row1
	LDRB r0, [r2, r3]
	ANDS R0,R0,R0	
	BEQ SHIFT
	BL LCD_char
	
	ADD r2, r2, #1		;fetch next character of string

	B ROW2	

;---------------------------------------------------------------;
;Task 3: Generate a rotating character string from right to left;
;---------------------------------------------------------------;

SHIFT
	
	MOV R0, #0x18
	BL LCD_cmd
	
	LDR R0, =0x2510
	BL DELAY

	B SHIFT
	
DONE
	
	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, LR}		;restore registers

	BX LR

EXIT

stop B stop

test_string1	DCB		"Hello World.", 0
test_string2	DCB		"It's Alive!", 0
				ALIGN
					
	END	