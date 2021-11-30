;----------------------------------------------------------------
;GPIO address and masks for Port0
PINSEL0			EQU	0xE002C000
PINSEL0GPIO		EQU	0xFFFF0000		;pin configuration for Task1 
	
	
;Pin direction address and masks for Port0
IO0DIR		EQU	0xE0028008		
IO0DIROUT	EQU	0x0000FF00		;pin direction for Task1 

PINSEL0GPIO_END		EQU 0xFF
IO0DIROUT_END		EQU	0xFFFF00FF

;Set / clear pins for each task
IO0SET		EQU 0xE0028004		
IO0CLR		EQU	0xE002800C		
;---------------------------------------------------------------

	GLOBAL LEDs
	
	IMPORT LED_delay
	IMPORT ISR_SUB
	
	AREA mycode,CODE,READONLY


;This task will turn on all eight LEDs using P0.08 - P0.15
LEDs

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r0, CPSR				;preserve status register
	STMFD	SP!, {r0}				

	LDR r2, =PINSEL0GPIO	;set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT		;set P0.08 - P0.15 to output
	BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	
	BL LED_ON			;Complete Task 1


	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, PC}		;restore registers
	
;------------------------------------------------------------;
;This subroutine will initialize pins based on masks provided;
;------------------------------------------------------------;

LED_pins
	
	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r1, CPSR				;preserve status register
	STMFD	SP!, {r1}				
	
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

	;**Stack stuff
	LDMFD	SP!, {r1}
	MSR		CPSR_f, r1				;restore status register flags
	LDMFD	SP!, {r0 - r12, PC}		;restore registers
	
;---------------------------------------------------------------------;
;Task 1																  ;
;---------------------------------------------------------------------;

LED_ON

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	MRS		r0, CPSR				;preserve status register
	STMFD	SP!, {r1}		
	
	LDR r2, =IO0CLR		;addresses for LED pins		
	LDR r3, =IO0SET		

	;Turn on LEDs
	STR r4, [r2]  
	
	BL LED_delay
	
	;Turn off LEDs
	STR r4, [r3] 
	
	BL LED_delay
	
	;**Stack stuff
	LDMFD	SP!, {r0}
	MSR		CPSR_f, r0				;restore status register flags
	LDMFD	SP!, {r0 - r12, PC}		;restore registers
	
stop	B	stop	
		
	END