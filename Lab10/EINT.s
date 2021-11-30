;External Interrupt Stuff
PINSEL1	EQU	0xE002C004
IO0DIR	EQU	0xE0028000
	
;EINT Address 
EXTINT 		EQU 	0xE01FC140	;address for EINTX
EXTMODE		EQU 	0xE01FC148	;address for level / edge
EXTPOLAR	EQU		0xE01FC14C	;address for rising /trailing
EINT0		EQU		0x4000
	
;------------------------------------------------------------------------------
;VIC Stuff
VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010	
VICIntEnClear	EQU	0xFFFFF014
	
;------------------------------------------------------------------------------
;masks for LEDS task
LED_ALL	EQU	0xFF00	 
LED_ALT	EQU	0xAA00
LED_FOUR EQU 0x0F00

;--------------------------------------------------------------

	GLOBAL EINT

	AREA mycode, CODE, READONLY


EINT
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	
	;Set pin stuff
	LDR r2, =0x1			;set P0.16 as EINT0	
	
	LDR	r0, =PINSEL1			;read contents of Port 0
	LDR	r1,[r0]
	MOV r3, #0x2
	BIC r1, r1, r3			;clear bit 1 for EINT0
	ORR	r1,r1,r2				;set bit 2 for EINT0
	STR	r1,[r0]

	
	;Set edge sensitive mode
	LDR r0, =EXTMODE
	LDR r1, [r0]
	LDR	r2, =0x1			
	ORR r1, r1, r2
	STR r1, [r0]
	
	;Set polarity to rising edge
	LDR r0, =EXTPOLAR
	LDR r1, [r0]
	LDR	r2, =0x1			
	BIC r1, r1, r2
	STR r1, [r0]

VIC_Setup

	;Enable interrupts that will be used
	
	;Assign interrupt as IRQ (0) or FIQ (1)
	
	;VICIntSelect
	;Write a zero to set as IRQ
	LDR r0, =VICIntSelect
	LDR r1, [r0]
	LDR r2, =EINT0
	ORR r1, r1, r2
	BIC r1, r1, r2
	STR r1, [r0]

	;VICIntEnable
	;Write a one to enable EINT0
	LDR r0,	=VICIntEnable	;;Set EINT0 to 1
	LDR r1,[r0]
	LDR r2, =EINT0	;0x4000
	ORR r1, r1, r2
	STR r1, [r0]

;;Silence external interrupt request
;Initialize flags to be off
	MOV r0, #1		;clear EINT0
	LDR r1, =EXTINT
	STR r0,	[r1]
	
	LDMFD	SP!, {r0 - r12, LR}	

STOP 	B STOP	
	END
