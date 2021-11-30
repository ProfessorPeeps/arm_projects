	IMPORT lcd_subs
	GLOBAL DELAY

;delay value (7 clk cyc / 12e6 Hz)

TEN_us		EQU		30		;wait 10 us (12e6 Hz / 6 instructions)

	GLOBAL DELAY
	AREA mycode,CODE,READONLY

DELAY	
	;**Stack stuff
	STMFD	SP!, {r0 - r1, LR}
	MRS		r1, CPSR
	STMFD	SP!, {r1}


	LDR r1, =TEN_us	    ;delay in increments of 10us	
	MUL r1, r0, r1		;increment by 10us

wait	
	SUBS r1, r1, #1		;loop delay until done 
	BNE wait
	
	;**Stack stuff
	LDMFD	SP!, {r1}
	MSR		CPSR_f, r1
	LDMFD	SP!, {r0 - r1, LR}	
	
	BX LR							;return to main 
		
		END