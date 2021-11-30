	IMPORT user_code

DELAYVAL	EQU	300000		;1 sec delay value (12e6 Hz / 4 clk cyc)^-1
		 
	GLOBAL delay
	AREA mycode,CODE,READONLY

delay
	LDR r9, =DELAYVAL

wait
	SUBS r9, r9, #1	
	BNE wait
	BX LR
		
		END