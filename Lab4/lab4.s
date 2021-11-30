	GLOBAL Reset_Handler

PINSEL0		EQU	0xE002C000		;pin select for port 0
IO0PIN		EQU	0xE0028000		;pin 8 from port 0
IO0DIR		EQU	0xE0028008		;set signal directions for pins
MASK1		EQU 0xFFFF0000		;mask for pin select, for input/output (dir)
MASK2		EQU 0x0000FFFF		;mask for pin select, for input/output (dir)

TASK1		EQU 0x00000000	;all on (needs AND)
TASK2		EQU 0x0000FF00	;all off (needs OR)
TASK3		EQU	0X0000AA00	;alternating (OR)

	AREA mycode,CODE,READONLY

Reset_Handler
	
	;set pin to GPIO	
	LDR r0, =MASK1		; this is our mask for ANDing( 1 ->0)
	LDR	r1, =PINSEL0	; PINSELO0 is a control register
	LDR r2, [r1]
	AND r2, r0, r2	 	; 
	STR	r2, [r1]		; bit 8 to 15 are set to GPIO
	
	;assign direction of port pin		
	LDR r0, =MASK2		; this is our mask for ANDing( 0 -> 1)
	LDR r3, =IO0DIR		;will mask with R0 which is already loaded
	LDR r4, [r3]
	ORR	r4, r0, r4
	STR	r4, [r3]		;bits 8 to 15 are set output
	
	;Do tasks
	LDR r0, =TASK3		;so task based on value needed
	LDR r6, =IO0PIN		;
	LDR r5, [r6]
	ORR	r5, r0, r5		;change b/w AND OR based on task
	STR	r5, [r6]
	
stop	B	stop
	END