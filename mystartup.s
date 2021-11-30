	IMPORT LAB	

MAMCR	EQU	0xE01FC000
MAMTIM	EQU	0xE01FC004	

	AREA RESET,CODE,READONLY
	ENTRY 
	
VECTORS
	LDR	PC,Reset_Addr
	LDR	PC,Undef_Addr
	LDR	PC,SWI_Addr
	LDR	PC,PAbt_Addr
	LDR	PC,DAbt_Addr
	NOP
	LDR	PC,IRQ_Addr
	LDR	PC,FIQ_Addr

Reset_Addr	DCD	Reset_Handler
Undef_Addr	DCD	UndefHandler
SWI_Addr	DCD	SWIHandler
PAbt_Addr	DCD	PAbtHandler
DAbt_Addr	DCD	DAbtHandler
			DCD	0

IRQ_Addr	DCD	IRQHandler
FIQ_Addr	DCD	FIQHandler
SWIHandler	B	SWIHandler
PAbtHandler	B	PAbtHandler
DAbtHandler	B	DAbtHandler
IRQHandler	B	IRQHandler
FIQHandler	B	FIQHandler
UndefHandler	B	UndefHandler

;This will initialize memory acceletor 
;to run at one clock cycle instead of seven
Reset_Handler

	LDR r1,=MAMCR
	MOV R0, #0x0
	STR R0, [R1]
	LDR R2,=MAMTIM
	MOV R0,#0x1
	STR R0,[R2]
	MOV R0,#0x2
	STR R0,[R1]
	B	LAB		
		END