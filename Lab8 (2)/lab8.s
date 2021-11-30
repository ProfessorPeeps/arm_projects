;----------------------------------------------------------------
;GPIO address and masks for Port0
PINSEL0			EQU	0xE002C000		;address for GPIO
PINSEL0GPIO1	EQU	0xFFFF0000		;pin configuration for Task1 
PINSEL0GPIO2	EQU	0x00FF0000		;pin configuration for Task3

;Pin direction address and masks for Port0		
IO0DIROUT1	EQU	0x0000FF00		;pin direction for Task 1 
IO0DIROUT2	EQU	0x00000F00		;pin direction for Task 3 
IO0DIROUT3	EQU 0x0000BF00		;pin direction for Task 4
IO0DIROUT4	EQU 0xFFFFBFFF		;pin direction for Task 4
IO0DIR		EQU	0xE0028008		;address for pin direction
	
;Set / clear pins for each task
IO0SET		EQU 0xE0028004		;Address to set pins 
IO0CLR		EQU	0xE002800C		;Address to clear pins
IO0PIN		EQU	0xE0028000		;Check pin data for Task 3

;Task 1 Masks
LED_ON1		EQU 0x00000100		;start at pin 8
LED_OFF1	EQU	0x0000FEFF		;negative mask for pin 8

;Task 3 - 4 Masks
TASK3_PINS	EQU	0x00000F00		;Task 3 - turn on/off 4 LEDs 
TASK4_PINS	EQU	0x0000FF00		;Task 4 - turn on/off 8 LEDs
;---------------------------------------------------------------

	IMPORT delay
	GLOBAL user_code
	AREA mycode,CODE,READONLY

;---------------------------------------------------------------------;
;Main program that calls subroutines to complete each task 			  ;
;---------------------------------------------------------------------;

user_code	

;Branch to execute a specific task. 
	B TASK4

;This task will produce a running LEDs using P0.08 - P0.15
TASK1

	LDR r2, =PINSEL0GPIO1	;set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT1		;set P0.08 - P0.15 to output for LEDs
	BL LED_pins				;Pass GPIO and pin direction masks to subroutine	
	B LED_running			;Complete Task 1

;This task will use a switch toggle to light up pins P0.08 - P.11
TASK3
	
	
	LDR r2, =PINSEL0GPIO2	;set P0.08 - P0.11 and P0.14 to GPIO 
	LDR r3, =IO0DIROUT2		;set P0.08 - P0.11 to output and P0.14 to input
	BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	B LED_button1			;Complete Task 3

;This task will use a switch toggle to light up pins P0.08 - P.15
TASK4

	LDR r2, =PINSEL0GPIO1	;set P0.08 - P0.15 to GPIO
	LDR r3, =IO0DIROUT3		;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	B LED_button2			;Complete Task 4
	

	
;---------------------------------------------------------------------;
;Task 1																  ;
;---------------------------------------------------------------------;

LED_running		

	;Initialization for Task 1
	LDR r0, =LED_OFF1	;masks for LED pins
	LDR r1, =LED_ON1
	LDR r2, =IO0CLR			
	LDR r3, =IO0SET		
		
	;Initialize counters for running LED
	LDR r4, =0x8		;loop for mask position
	LDR r5, =0x1		;execute task 1 two times
	
LED_START
	 
	;Turn off LEDs based on mask
	STR r0, [r3]  
	
	;Turn on LEDs based on mask
	STR r1, [r2]
	
	;Call a delay before running to next LED 
	BL delay				
	
	PRESERVE8
	
LED_NEXT

	;Check if P0.15 is reached
	SUBS	r4, r4, #1  
	CMP		r4, #0	
	
	;If true, update masks to use P0.08
	ROREQ	r0, r0, #7		;clear mask 
	ROREQ	r1, r1, #7		;set mask
	BEQ		LED_CHECK		;check # of executions
	
	;If false, update masks to use next pin 
	LSL 		r0, r0, #1		;clear mask		
	LSL			r1, r1, #1		;set mask
	B			LED_START		;repeat process until execution complete

LED_CHECK

	;check # of executions
	CMP		r5, #0			;check if 2 executions have occured
	BEQ		user_code		;Exit Task 1 if true
	SUBNE	r5, r5, #1		;update # of executions 
	LDR		r4, =0x8		;reinitialize mask position
	B		LED_START		;one execution completed
	
;---------------------------------------------------------------------;
;Task 3																  ;
;---------------------------------------------------------------------;

LED_button1

	;Initialization for Task 3
	LDR r0, =TASK3_PINS		;Mask for LEDs on/off
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
LED_OFF

	;Turn off LEDs
	STR r0, [r3]  
	BL TASK3_ISPRESSED
	
LED_ON	
	
	;Turn on LEDs
	STR r0, [r2] 	
	BL TASK3_ISPRESSED	

;---------------------------------------------------------------------;
;Task 4																  ;
;---------------------------------------------------------------------;

LED_button2

;Initial start, turn off LEDs.
LED_OFF2

	;Initial State: set GPIO and pin direction 
	LDR r2, =PINSEL0GPIO1		;Set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT1		;Set P0.08 - P0.15 to output direction 	
	BL LED_pins

	;Initialization for initial state	
	LDR r0, =TASK4_PINS	;Mask for LEDs on/off
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins

	;Turn off all LEDs
	STR r0, [r3]
	
	;Next State: set GPIO and pin direction 
	LDR r2, =PINSEL0GPIO1		;Set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT4		;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins

	;Check P0.14 is pressed
	BL TASK4_ISPRESSED
	
;Button has been pressed, turn on LEDs.
LED_ON2

	;Next State: set GPIO and pin direction
	LDR r2, =PINSEL0GPIO1		;Set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT1		;set P0.08 - P0.15 to output and P0.14 to Output
	BL LED_pins
	
	;Initialization for next state
	LDR r0, =TASK4_PINS
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
	;Turn on all LEDs	
	STR r0, [r2] 	
	
	;Call a delay before checking if button press.
	BL delay

checkon	
	
	;Check State: set GPIO and pin direction
	LDR r2, =PINSEL0GPIO1		;Set P0.08 - P0.15 to GPIO 
	LDR r3, =IO0DIROUT4		;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins
	
	;Read pin data
	LDR r4, =IO0PIN	
	LDR r5, [r4]
	
	;Check if P0.14 is pressed
	LDR		r4, =0x4000	 	;check if P0.14 is pressed
	AND 	r6, r5, r4		;compare previous pin data with current data
	CMP		r4, r6			
	BEQ LED_ON2
	
	;Check for button press
	BL TASK4_ISPRESSED	


;--------------------------------------------------------------;
;This subroutine will initialize pins based on masks provided. ;
;r2 (GPIO) and r3 (IO0DIR) are values passed to this subroutine;
;--------------------------------------------------------------;


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


;-------------------------------------------------------------------;
;This subroutine will check button presses for Task 3				;
;-------------------------------------------------------------------;

TASK3_ISPRESSED

CHECK
	;update pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	
	LDR		r4, =0x4000	 	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	
	BEQ		CHECK 		 ;if true, no button press was read
	BL		delay			 ;apply a delay to confirm button press

;Confirm that button is still being pressed
CONFIRM_PRESSED
	
	;update pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	
	LDR		r4, =0x4000	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	BEQ		CHECK		 ;if true, no button press was read
	BL		delay			 ;apply a delay to confirm button press

STATE_CHECK
	
	;grab current pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	LDR r6, =0xBF00

	AND r5, r5, r6
	CMP r5, r6		
	BEQ LED_ON		;if true, State 0	(OFF -> ON)	
	B	LED_OFF		;else, state 1		(ON -> OFF)


;-------------------------------------------------------------------;
;This subroutine will check button presses for Task 4				;
;-------------------------------------------------------------------;

TASK4_ISPRESSED

CHECK2
	;update pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	
	LDR		r4, =0x4000	 	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	
	BEQ		CHECK2 		 ;if true, no button press was read
	BL		delay			 ;apply a delay to confirm button press

;Confirm that button is still being pressed
CONFIRM_PRESSED2
	
	;update pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	
	LDR		r4, =0x4000	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	BEQ		CHECK2		 ;if true, no button press was read
	BL		delay			 ;apply a delay to confirm button press

STATE_CHECK2
	
	;grab current pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	LDR r6, =0xBF00

	AND r5, r5, r6
	CMP r5, r6		
	BEQ LED_ON2		;if true, State 0	(OFF -> ON)	
	B	LED_OFF2		;else, state 1		(ON -> OFF)

DONE 

stop	B	stop	
		
	END