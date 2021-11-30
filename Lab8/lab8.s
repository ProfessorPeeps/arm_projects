	IMPORT delay
PINSEL0		EQU	0xE002C000
IO0DIR		EQU	0xE0028008	
IO0PIN		EQU	0xE0028000

MASK1		EQU	0x0000FFFF	;mask for GPIO
MASK2		EQU	0xFFFF0000	;mask for pin direction
TASK1		EQU	0xFFFFFEFF		;start at pin 8
MASK3		EQU 0x0000FF00	
TASK2		EQU 0xFFFFFDFF

	GLOBAL user_code
	AREA mycode,CODE,READONLY

user_code	

	LDR	r1, =PINSEL0	; PINSELO0 is a control register
	LDR r2, [r1]
	LDR r0, =MASK1		; this is our mask for ANDing( 1 ->0)
	AND r2, r0, r2	 	; 
	STR	r2, [r1]		; bit 8 to 15 are set to GPIO
	
	LDR r0, =MASK3		; this is our mask for ANDing( 0 -> 1)
	LDR r3, =IO0DIR		;will mask with R0 which is already loaded
	LDR r4, [r3]
	ORR	r4, r0, r4
	STR	r4, [r3]
	
	;TURN ON 8 INTIALLY
	
	

	
START
	LDR r0, =TASK1		;start at pin 8
	LDR r1, =IO0PIN
	LDR r2, [r1]	
	ORR r3, r0, r1
	STR r3, [r1]
	;BL delay
	
	
	LDR r5, =0x8 			;loop 8 times
	
NEXT
	LDR r4, =MASK3	
	LDR r2, [r1]
	ORR r3, r4, r1
	STR r3, [r1]
	
	BL delay

	
	
	LDR r2, [r1]
	ORR r3, r0, r1
	STR r3, [r1]
	
	LSL r0, r0, #1
	SUBS r5, r5, #1
	CMP r5, #0 
	ROREQ r0, r0, #8
	ADDEQ r5,r5, #8
	
	
	
	BL delay
	;AND		r0, r0, r5
	;ORR		r3, r4, r1
	;STR 	r3, [r1]
	;ROR 	r0, #7
	
	;ADD   	r5, r5, #1
	;BEQ 	START
	B 		NEXT
	
	
	;call sub
;	BL delay


	;STR r5, [r6,#IO0CLR]

	;BL delay
	
	;return
	
	;B LEDnext
	
;------------------------------------------------------
	;call sub
	;STMEA	SP!, {r0-r2, LR}	;preserve r0
	;MRS	r2, CPSR		;preserve flags, place in r2

	;BL delay			;call subroutine

	;MSR	CPSR_f,	r2
	;LDMEA	SP!, {r0-r2, LR}		
;------------------------------------------------------

stop	B	stop	
		
	END


