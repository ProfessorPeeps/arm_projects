	IMPORT user_code

DELAYVAL	EQU	500000		;delay value (4 clk cyc / 12e6 Hz)

	GLOBAL delay
	AREA mycode,CODE,READONLY

delay
	LDR r3, =DELAYVAL

wait
	SUBS r3, r3, #1	
	BNE wait
	BX LR
		
		END
	

	

	



