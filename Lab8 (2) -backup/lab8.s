;----------------------------------------------------------------
;GPIO address and masks for Port0
PINSEL0			EQU	0xE002C000
PINSEL0GPIO1	EQU	0xFFFF0000		;pin configuration for Task1 
PINSEL0GPIO2	EQU	0x00FF0000		;pin configuration for Task3

;Pin direction address and masks for Port0
IO0DIR		EQU	0xE0028008		
IO0DIROUT1	EQU	0x0000FF00		;pin direction for Task1 
IO0DIROUT2	EQU	0x00000F00		;pin direction for Task3 
IO0DIROUT3	EQU 0xFFFF00FF

;Set / clear pins for each task
IO0SET		EQU 0xE0028004		
IO0CLR		EQU	0xE002800C		
IO0PIN		EQU	0xE0028000		;Check pin data for Task 3
	
;Bit value for checking for button presses
LED14_ON	EQU	0x00004000			
LED14_OFF	EQU	0xFFFFBFFF

;not used
LED_ON1		EQU 0x00000100		;data pins for Task1
LED_OFF1	EQU	0xFFFFFEFF	
LED_OFF2		EQU	0xFFFFBFFF


;---------------------------------------------------------------

	IMPORT delay
	GLOBAL user_code
	AREA mycode,CODE,READONLY

user_code	

;This task will produce a running LEDs using P0.08 - P0.15
TASK1
	;LDR r2, =PINSEL0GPIO1	;set P0.08 - P0.15 to GPIO 
	;LDR r3, =IO0DIROUT1		;set P0.08 - P0.15 to output
	;BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	
	;B LED_running			;Complete Task 1

;This task will use a switch toggle to light up pins P0.08 - P.11
TASK3
	
	;LDR r2, =PINSEL0GPIO2	;set P0.08 - P0.11 and P0.14 to GPIO 
	;LDR r3, =IO0DIROUT2		;set P0.08 - P0.11 to output and P0.14 to input
	;BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	;B LED_button1				;Complete Task 3
	
TASK4
	LDR r2, =PINSEL0GPIO1
	LDR r3, =0xBF00			;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins				;Pass GPIO and pin direction masks to subroutine
	B LED_button2
	
	B DONE
	
;---------------------------------------------------------------------;
;Task 1																  ;
;---------------------------------------------------------------------;

LED_running		

	;initiialize pins
	LDR r0, =LED_OFF1	;masks for LED pins
	LDR r1, =LED_ON1
	LDR r2, =IO0CLR		;addresses for LED pins		
	LDR r3, =IO0SET		
		
	;Initialize counters for running LED
	LDR r4, =0x8		;loop for mask position
	LDR r5, =0x0		;execute task 1 three times
	
LED_START
	 
	;Turn off LEDs based on mask
	STR r0, [r3]  
	
	;Turn on LEDs based on mask
	STR r1, [r2]
	
	;Apply 1 sec delay 
	BL delay				
	
LED_NEXT

	;Check if P0.15 is reached
	SUBS	r4, r4, #1  
	CMP	r4, #0	
	
	;If true, update masks to use P0.08
	ROREQ	r0, r0, #7		;clear mask 
	ROREQ	r1, r1, #7		;set mask
	BEQ	LED_CHECK			;check # of executions
	
	;If false, update masks to use next pin 
	LSL 		r0, r0, #1		;clear mask		
	LSL		r1, r1, #1		;set mask
	B		LED_START		;repeat process until execution complete

LED_CHECK
	;check # of executions
	CMP		r5, #0			;check if 3 executions have occured
	BEQ		TASK3			;Exit Task 1 if true
	SUBNE	r5, r5, #1		;update # of executions 
	LDR		r4, =0x8		;reinitialize mask position
	B		LED_START		;one execution completed
	
;---------------------------------------------------------------------;
;Task 3																  ;
;---------------------------------------------------------------------;

LED_button1

	;initialize pins	(set masks)
	LDR r0, =0xF00
	
	;set up clearing / setting
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
;Initial state, LEDs are off
LEDS_OFF	
	STR r0, [r3]  
	BL IS_PRESSED
	
;Button has been pressed, light up LED
LEDS_ON	
	
	;Button press confirmed, turn ON
	STR r0, [r2] 	;turn LEDs on
	
	;Check for button press
	BL IS_PRESSED	;check button press


;---------------------------------------------------------------------;
;Task 4																  ;
;---------------------------------------------------------------------;


LED_button2

	;initialize pins	(set masks)
	LDR r0, =0xBF00
	;set up clearing / setting
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
;Initial state, LEDs are off
LEDS_OFF2
	LDR r2, =0x0
	LDR r3, =0xFF00			;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins
	
	LDR r0, =0xFF00
	
	;set up clearing / setting
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
	;Turn off all LEDs
	STR r0, [r3]
	
	;Set P0.14 to input
	LDR r2, =0x0
	LDR r3, =0xFFFFBFFF			;set P0.08 - P0.15 to output and P0.14 to input
	BL LED_pins

	;Check P0.14 is pressed
	BL IS_PRESSED
	
;Button has been pressed, light up LED
LEDS_ON2
	LDR r2, =0x0
	LDR r3, =0xFF00			;set P0.08 - P0.15 to output and P0.14 to Output
	BL LED_pins
	
	LDR r0, =0xFF00
	;set up clearing / setting
	LDR r2, =IO0CLR		;clearing pins	
	LDR r3, =IO0SET		;setting pins
	
	STR r0, [r2] 	;turn LEDs on
	
	BL delay

checkon	
	
	;Button press confirmed, turn ON
	
	LDR r2, =0x0				
	LDR r3, =0xFFFFBFFF			;P0.14 to input
	BL LED_pins
	
	LDR r4, =IO0PIN	;Read P0.14
	LDR r5, [r4]
	
	LDR		r4, =0x4000	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	BEQ LEDS_ON2
	;Check for button press
	BL IS_PRESSED	;check button press




;---------------------------------------------------------------------;
;Task 4		- not working														  ;
;---------------------------------------------------------------------;

;LED_button2
	
	;LDR r0, =0xFF00
	;;set up clearing / setting
	
	;LDR r5, =IO0CLR		;clearing pins	
	;LDR r6, =IO0SET		;setting pins
	
;;Initial state, LEDs are off
;LEDS_INIT	

	;STR r0, [r6]  
	;BL IS_PRESSED

;;Button has been pressed, light up LED
;LEDS_ON2	

	;;Change P0.14 to output
	;LDR r3, =0xFF00				;set P0.08 - P0.15 to output
	;BL LED_pins
	
	;;Turn on all LEDs
	;STR r0, [r5]

	;;BL	delay			 

	;;Change P0.14 to input
	;LDR r3, =0xBF00	
	;BL LED_pins

	;BL	delay

	;BL IS_PRESSED

;LEDS_OFF2
	
	;;Change P0.14 to output
	;LDR r3, =0xFF00				;set P0.08 - P0.15 to output
	;BL LED_pins

	;;Turn on off LEDs
	;STR r0, [r6]
	
	;;Change P0.14 to input
	;LDR r3, =0xBF00	
	;BL LED_pins

	;BL	delay

	;BL IS_PRESSED
	
;------------------------------------------------------------;
;This subroutine will initialize pins based on masks provided;
;------------------------------------------------------------;

;r2 (GPIO) and r3 (IO0DIR) are values passed to this subroutine
;before it is called  

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

;TASK 3 subroutine
;-------------------------------------------------------------------;
;This subroutine will constantly check if the push button is pressed;
;-------------------------------------------------------------------;

IS_PRESSED	

CHECK
	;update pin info
	LDR r4, =IO0PIN
	LDR r5, [r4]
	
	;shslfk
	
	LDR		r4, =0x4000	 ;check if P0.14 is pressed
	AND 	r6, r5, r4		 ;compare previous pin data with current data
	CMP		r4, r6			
	
	;sjklhlkfha
	
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
	BEQ LEDS_ON2		;if true, State 0	(OFF -> ON)	
	B	LEDS_OFF2	;else, state 1		(ON -> OFF)

;TASK4 subroutine
;-------------------------------------------------------------------;
;This subroutine will constantly check if the push button is pressed;
;-------------------------------------------------------------------;

;IS_PRESSED	

;CHECK
	;;update pin info
	;LDR r4, =IO0PIN
	;LDR r5, [r4]
	
	;LDR		r4, =0x4000	 ;check if P0.14 is pressed
	;AND 	r6, r5, r4		 ;compare previous pin data with current data
	;CMP		r4, r6			
	;BEQ		CHECK 		 ;if true, no button press was read
	;BL		delay			 ;apply a delay to confirm button press

;;Confirm that button is still being pressed
;CONFIRM_PRESSED
	
	;;update pin info
	;LDR r4, =IO0PIN
	;LDR r5, [r4]
	
	;LDR		r4, =0x4000	 ;check if P0.14 is pressed
	;AND 	r6, r5, r4		 ;compare previous pin data with current data
	;CMP		r4, r6			
	;BEQ		CHECK		 ;if true, no button press was read
	;BL		delay			 ;apply a delay to confirm button press

;STATE_CHECK
	
	;;grab current pin info
	;LDR r4, =IO0PIN
	;LDR r5, [r4]
	;LDR r6, =0xBF00
	;AND r5, r5, r6
	;CMP r5, r6		
	;BEQ LEDS_ON2		;if true, State 0	(OFF -> ON)	
	;B	LEDS_OFF2	;else, state 1		(ON -> OFF)

DONE 

stop	B	stop	
		
	END