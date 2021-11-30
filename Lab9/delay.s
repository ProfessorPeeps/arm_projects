	IMPORT user_code
	IMPORT LCD_cmd
;delay value (4 clk cyc / 12e6 Hz)

	GLOBAL DELAY
	AREA mycode,CODE,READONLY

DELAY


wait
	SUBS r9, r9, #1	
	BNE wait
	BX LR
		
		END
	

	

	



