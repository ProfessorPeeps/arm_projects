;-------------------------------------------------------------
	
	GLOBAL user_code
	
	IMPORT EINT
	IMPORT ISR_SUB
	IMPORT LED_delay
		
	AREA mycode,CODE,READONLY
	ENTRY
	
user_code
	
	;Call a software interrupt (task 2 and 3)
	SWI #1	
	
	BL LED_delay	;call a delay within each subroutine
	
	SWI #2
	
	BL LED_delay	
	
	SWI #3
	
stop B stop

	END	