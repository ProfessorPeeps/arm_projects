	IMPORT lcd_subs

;DELAY
MAMCR	EQU	0xE01FC000
MAMTIM	EQU	0xE01FC004
	
;Standard definitions of Mode bits and Interrupt (I & F) flags in PSR
Mode_USR	EQU	0x10
I_Bit		EQU	0X80	;when I bit set, IRQ disabled
F_Bit		EQU	0X40	;when F bit set, FIQ disabled

;Definitions of User Mode Stack and Size
USR_Stack_Size	EQU	0x00000100
SRAM		EQU	0x40000000
Stack_Top	EQU	SRAM+USR_Stack_Size

	AREA RESET,CODE,READONLY
	ENTRY
	ARM 
	
VECTORS
	LDR	PC,Reset_Addr
	LDR	PC,Undef_Addr
	LDR	PC,SWI_Addr
	LDR	PC,PAbt_Addr
	LDR	PC,DAbt_Addr
	NOP
	LDR	PC,IRQ_Addr
	LDR	PC,FIQ_Addr

Reset_Addr	DCD	lcd_subs
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

;--------------------------------------------------------

;Enter User Mode with interrupts enabled	
	MOV	R14, #Mode_USR
	BIC	R14, R14, #(I_Bit+F_Bit)
	MSR	cpsr_c, r14
;initialize stack, FD
	LDR	SP, =Stack_Top
;load start address of user code into PC
	LDR	pc, =lcd_subs

;--------------------------------------------------------
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
	B	lcd_subs	
		END