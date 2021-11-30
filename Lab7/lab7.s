num			EQU	4			;value for Task1
char		EQU	0x0000006F	;value for Task3 (char o in hex)
	
IO0_BASE	EQU	0xE0028000	;BR address for Task4
IO0PIN		EQU	0		;base register
IO0DIR		EQU	0x8		;pin direction
IO0SET		EQU	0x4		;set pins
IO0CLR		EQU	0xC		;clear pins
DELAYVAL	EQU	3		;delay value (4 clk cyc / 12e6 Hz)
MASK1		EQU	0xFFFF0000	;mask for GPIO
MASK2		EQU	0x0000FFFF	;mask for pin direction
TASK4		EQU	0xFF00		;use all LEDs

	GLOBAL user_code
	AREA mycode,CODE,READONLY

user_code	
	
	;initialize task 1
	MOV  r0, #num		;num value (counter)
	MOV r1, #0			;initialize sum (end result)
	
	;initialize task4
	MOV r10, #1		;loop 5 times
	
	;initialize task5

; *** Task 1 - sum 
SUM	
	ADD		r1, r0, r1	;do sum
	SUBS	r0, r0, #1	;decrement 
	BNE  	SUM			;repeat sum, otherwise exit
	
; *** Task 3 - findChar 
CHAR
	MOV		r2, #0			;counter for offset
	MOV		r3, #0			;counter for DBC index
	ADR		r0, STRING		;read address
	ADR		r5, LETTER
	
LOOP
	LDRB	r6, [r5]		;letter to find
	LDRB	r4, [r0, r3]	;grab char from DCB string
	ANDS	r4, r4, r4		;check if value is null (0)
	BEQ		LED				;exit to next task
	
	CMP		r4, r6			;check for 'o'
	ADDEQ	r2, r2, #1		;increment if match
	ADDS	r3, r3, #1		;increment indx
	BNE		LOOP
		
; *** Task 4 - LEDs 
LED	
	LDR r0, =MASK1		;initialize GPIO
	LDR r1, =IO0_BASE	
	STR r0, [r1, #IO0PIN]		
	
	LDR r0, =MASK2		;initialize pin direction
	STR r0, [r1,#IO0DIR]	

LEDoff	
	LDR r5, =TASK4
	LDR r6, =IO0_BASE	;initial state, keep LEDs off
	STR r5, [r6,#IO0CLR]
	BL	wait

LEDon	

	LDR r5, =TASK4
	LDR r6, =IO0_BASE		
	STR r5, [r6,#IO0SET]
	BL	wait
	BL	CHECK

CHECK
	SUBS r10, r10, #1	;start LED loop	
	BEQ  COUNT		;exit if done 5 times
	B 	LEDoff
wait
	LDR r9, =DELAYVAL

COUNTER
	SUBS r9, r9, #1	
	BNE COUNTER
	BX LR

; *** Task 5 - Count ones 
COUNT
	MOV r3, #0			;total ones (final result)
	MOV r5, #0			;initial address starts at zero (index)
	MOV r4, #10			;inner loop 10 times
	ADR r0, user_code 	; Address of user_code
	LDR r6, [r0, r5]	; grab first instruction
						;start count
	
INNER				
	LSRS   r6, r6, #1	;shift instruction right
	ADDCS r3, r3, #1	;increment only if carry is set
	CMP		r6, #0   	;is num equal
	BEQ	  STORE			;finished counting first instruction
	B	INNER
						;fetch next instruction
OUTER									
	SUBS R4, r4, #1			;decrement loop counter 
	ADD R5, R5, #4			;offset index - fetch next instruction
	CMP R4, #0				;is loop done?
	BEQ EXIT
	MOV r3, #0		
	LDR r6, [r0, r5]
	B	INNER

STORE			;STORE INTO DCD
	;LDR r7, =RESULT
	;LDR r7, R3
	B	OUTER
	
EXIT

stop	B	stop
	
STRING	DCB	"Hello World!", 0		;string to read
LETTER	DCB "o", 0					;char to find
		ALIGN
			
		AREA mydata, DATA, READWRITE	
RESULT	DCD	0
SIZE	SPACE 10
		ALIGN
		
		
		END
	

	

	



