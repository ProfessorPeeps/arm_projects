;------------------------------------------------------------------------		
DELAYVAL	EQU	3000000		;1 sec delay value (12e6 Hz / 4 clk cyc)^-1
;------------------------------------------------------------------------

	IMPORT LEDs
	GLOBAL LED_delay
		
	AREA mycode,CODE,READONLY


LED_delay
	LDR r9, =DELAYVAL

wait
	SUBS r9, r9, #1	
	BNE wait
	BX LR

	END