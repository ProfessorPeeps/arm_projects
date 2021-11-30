;----------------------------------------------------------
IO0_BASE	EQU 0xE0028000	  ;base register address 
IO0PIN		EQU 0		  ;value register
IO0DIR		EQU 0x8		  ;pin direction register
IO0SET		EQU 0x4		  ;set pins
IO0CLR		EQU 0xC		  ;clear pins
;----------------------------------------------------------
DELAYVAL	EQU 500000	  	  ;delay value (4 clk cyc / 12e6 Hz)
							  ;3000000 in hex
MASK1		EQU 0xCFFF0000	  ;mask for GPIO
MASK2		EQU 0x0000BFFF	  ;mask for pin 14
MASK14		EQU	0x4000		  ;check 14
TASK		EQU	0xBF00		  ;deal with pins 8 - 11
TASK2		EQU 0x0F00		 ;for open	
	GLOBAL LAB		
	AREA mycode,CODE,READONLY

LAB
	;Set pin 14 to push, everything else to GPIO
	LDR r0, =MASK1		;load mask for deselect
	LDR r1, =IO0_BASE	;base register
	STR r0, [r1, #IO0PIN]	;offset to I00PIN	

	;SET PIN 14 TO OUTPUT
	LDR r0, =MASK2			;check bits
	STR r0, [r1,#IO0DIR]	;pins to output and push to input

	;Initially Pins 8,9,10,11 off
	
LEDoff				;Turn off LEDs
	LDR r5, =TASK2	
	LDR r6, =IO0_BASE
	STR r5, [r6,#IO0CLR]
	
;check if pressed, loop if not true	
Check

	;grab contents of pins
	LDR r7, [r1,#IO0PIN]
	MOV r8, #MASK14
	AND r9,r7,r8
	TST	r9,r8
	BEQ Check		;If same means button is not pressed
	
	;delay
	BL wait

;Makes sure it is still pressed 
	LDR r7, [r1,#IO0PIN]
	MOV r8, #MASK14
	AND r9,r7,r8
	TST	r9, r8
	BEQ LEDoff		;If same means button is not pressed
	B	LEDon		;If Pin 14 pressed, branch LEDon
	
	
;If Pin 14 pressed, turn on	
LEDon				;Turn on LEDs
	LDR r5, =TASK	
	LDR r6, =IO0_BASE		
	STR r5, [r6,#IO0SET]
	BL	Check		;Check to see if still pressed	

;delay to confirm press
wait		;Wait for 3 seconds
		
	LDR r9, =DELAYVAL	;set counter
	
	
COUNTER
	SUBS r9, r9, #1	
	;BX LR	;Go back to original location
	BNE COUNTER
	BX LR

stop	B	stop
	END



