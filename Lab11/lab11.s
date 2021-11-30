;-------------------------------------------------------------
;GPIO addressfor Port0
PINSEL0		EQU	0xE002C000		
PINSEL1		EQU	0xE002C004
P0DIR		EQU	0x201000
;Pin direction address for Port0
IO0DIR		EQU	0xE0028008		
IO1DIR		EQU 0xE0028018
	
;Masks for GPIO & pin direction
P0GPIO		EQU 0x03000000
P1GPIO		EQU	0x00000C00

;-------------------------------------------------------------
	
	GLOBAL user_code
		
	AREA mycode,CODE,READONLY
	ENTRY
	
user_code
	
	;set pin 12 & 21 to gpio
	LDR r2, =P0GPIO			;set P0.12
	LDR r3, =P0DIR	
	BL LED_pins				;Pass GPIO  to subroutine
	
	LDR r4, =P1GPIO			;set P1.21 
	BL LED_pins				;Pass GPIO to subroutine

	B DONE
;--------------------------------------------------------------	
LED_pins

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r1, CPSR				;preserve status register
	STMFD	SP!, {r1}				
	
	;------
	;PORT0
	;------
	;Set GPIO for Port0
	LDR	r0, =PINSEL0		;read pins of Port0
	LDR r1, [r0]
	BIC r1, r1, r2		 	
	STR	r1, [r0]			
	
	;Set pin direction for pins
	LDR	r0, =IO0DIR			
	LDR r1, [r0]
	AND r1, r1, r3				;clear pins
	ORR	r1, r1, r3				;set pins
	STR r1, [r0]	

	;------
	;PORT1
	;------
	;Set GPIO for Port0
	LDR	r0, =PINSEL1		;read pins of Port0
	LDR r1, [r0]
	BIC r1, r1, r4		 	
	STR	r1, [r0]			

	;**Stack stuff
	LDMFD	SP!, {r1}
	MSR		CPSR_f, r1				;restore status register flags
	LDMFD	SP!, {r0 - r12, PC}		;restore registers
	
;------------------------------------------------------------------	
DONE 

stop B stop

	END	