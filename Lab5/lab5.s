;----------------------------------------------------------
IO0PIN		EQU 0		  ;value register
IO0DIR		EQU 0x8		  ;pin direction register
IO0SET		EQU 0x4		  ;set pins
IO0CLR		EQU 0xC		  ;clear pins
;----------------------------------------------------------

IO0_BASE	EQU 0xE0028000	  ;base register address 
DELAYVAL	EQU 3000000  ;delay value (4 clk cyc / 12e6 Hz)
							  ;3000000 in hex
MASK1		EQU 0xFFFF0000	  ;mask for pin select, for input/output (dir)
MASK2		EQU 0x0000FFFF	  ;mask for pin select, for input/output (dir)
TASK		EQU 0xFF00
	
	GLOBAL LAB		
	AREA mycode,CODE,READONLY


LAB
	;set pin to GPIO	
	LDR r0, =MASK1		;load mask for deselect
	LDR r1, =IO0_BASE	;base register
	STR r0, [r1, #IO0PIN]	;offset to I00PIN	

	;set signal direction for pins		
	LDR r0, =MASK2		;load mask for select
	LDR r3, =IO0_BASE	
	STR r0, [r3, #IO0DIR]	;offset to IO0DIR
	
	;set on
LEDon				;Turn on LEDs
	LDR r5, =TASK	
	LDR r6, =IO0_BASE		
	STR r5, [r6,#IO0SET]
	BL	wait		;wait 3 seconds
	
	;set off
LEDoff				;Turn off LEDs	
	LDR r5, =TASK	
	LDR r6, =IO0_BASE		
	STR r5, [r6, #IO0CLR]
	BL	wait		;wait 3 seconds
	B	LEDon		;Star over

	;delay
wait		;Wait for 3 seconds
		
	LDR r9, =DELAYVAL	;set counter
	
COUNTER
	SUBS r9, r9, #1	
	;BX LR	;Go back to original location
	BNE COUNTER
	BX LR

stop B	stop
	END