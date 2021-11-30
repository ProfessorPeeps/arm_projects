;--------------------------------------------------------------------			
;Memory Accelerator Registers
MAMCR	EQU	0xE01FC000
MAMTIM	EQU	0xE01FC004

;Mode bits
MODE_USR	EQU	0x10	;User mode
MODE_FIQ	EQU	0x11	;FIQ mode
MODE_IRQ	EQU	0x12	;IRQ mode
MODE_SVC	EQU 0x13	;Supervisor mode
MODE_ABT	EQU 0x17	;Abort mode
MODE_UND	EQU 0x1B	;Undefined mode
MODE_SYS	EQU 0x1F	;System mode

;Interrupt Bits
I_Bit		EQU	0x80	;when I bit set, IRQ disabled
F_Bit		EQU	0x40	;when F bit set, FIQ disabled

;Define Stack Size 
USR_Stack_Size	EQU	0x100						;maybe setup fixed stack size to call?
FIQ_Stack_Size	EQU	0x100
IRQ_Stack_Size	EQU	0x100
SVC_Stack_Size	EQU	0x100
ABT_Stack_Size	EQU	0x100
UND_Stack_Size	EQU	0x100
SYS_Stack_Size	EQU	0x100
	
Stack_Top		EQU	SRAM_BASE + USR_Stack_Size	+ SYS_Stack_Size	+ UND_Stack_Size	+ ABT_Stack_Size	+ IRQ_Stack_Size + FIQ_Stack_Size + SVC_Stack_Size
SRAM_BASE		EQU	0x40000000					;default base value
	
;------------------------------------------------------------------------------

;VIC Stuff
VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010	
VICIntEnClear	EQU	0xFFFFF014

VICVectCntl0	EQU	0xFFFFF200
VICVectAddr0	EQU	0xFFFFF100
VICVectAddr		EQU	0xFFFFF030
TIMER0_IR		EQU	0xE0004000	

;masks for VIC
TIMER0			EQU	0x10

;Pin config stuff
PINSEL0		EQU	0xE002C000		
PINSEL1		EQU	0xE002C004

;modify pins
IO0SET		EQU 0xE0028004		
IO0CLR		EQU	0xE002800C		

IO1SET		EQU 0xE0028014		
IO1CLR		EQU	0xE002801C	

;------------------------------------------------------------


;***
;PCLK -> CTCR & TCR -> TXMCR & TC(?) -> MCR -> IR
;***

;Prescaler Addresses (PCLK)
T0PR		EQU	0xE000400C
T1PR		EQU	0xE000800C

;Timer/Counter Mode Addresses (CTCR)
T0CTCR		EQU	0xE0004070
T1CTCR		EQU	0xE0004070

;Timer Control  Addresses (TCR)
T0TCR		EQU	0xE0004004
T1TCR		EQU	0xE0008004

;Match register Addresses for TIMER0 (T0MRX)
T0MR0		EQU	0xE0004018
T0MR1		EQU	0xE000401C
T0MR2		EQU	0xE0004020
T0MR3		EQU	0xE0004024

;Match register Addresses for TIMER1 (T1MRX)
T1MR0		EQU	0xE0008018
T1MR1		EQU	0xE000801C
T1MR2		EQU	0xE0008020
T1MR3		EQU	0xE0008024

;Match control register Addresses (MCR)
T0MCR		EQU	0xE0004014
T1MCR		EQU	0xE0008014

;External Match register Addresses (EMR)
T0EMR		EQU	0xE000403C
T1EMR		EQU	0xE000803C

;Match values 
MATCH0		EQU	40200
MATCH1		EQU	80400
MATCH2		EQU	120600
MATCH3		EQU	160800

;Interrupt Mask for Match registers
MATCH_IR	EQU 0x649	;(011001001001)


;-------------------------------------------------------------
		
	IMPORT user_code
	

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
	;LDR PC,IRQ_Addr		;Task 2: Non-Vectored IRQ
	LDR PC, [PC, #-0x0FF0]	;Task 3: Vectored IRQ
	LDR	PC,FIQ_Addr

Reset_Addr	DCD	Reset_Handler
Undef_Addr	DCD	UndefHandler
SWI_Addr	DCD	SWIHandler			;SWI interrupt
PAbt_Addr	DCD	PAbtHandler
DAbt_Addr	DCD	DAbtHandler
		DCD	0
IRQ_Addr	DCD	IRQHandler		
FIQ_Addr	DCD	FIQHandler

SWIHandler B SWIHandler
PAbtHandler	B	PAbtHandler
DAbtHandler	B	DAbtHandler
IRQHandler	B	ISR_SUB				;IRQ interrupt
FIQHandler	B	FIQHandler
UndefHandler	B	UndefHandler

;-----------------------------------------------------
;Initialize MAM to run at one clock cycle instead of seven. Then, branch to main code.	
Reset_Handler

	LDR r1,=MAMCR
	MOV R0, #0x0
	STR R0, [R1]
	LDR R2,=MAMTIM
	MOV R0,#0x1
	STR R0,[R2]
	MOV R0,#0x2
	STR R0,[R1]
	
;----------------------------------------------------------

TIMER

	;***
	;PCLK -> CTCR & TCR -> TXMCR -> MCR -> IR
	;***

	;deal with CTCR
	LDR r0, =T0CTCR
	MOV r1, #0
	STR r1, [r0]

	;deal with prescaler PCLK 
	LDR r0, =T0PR	
	MOV r1, #0
	STR r1, [r0]	;remove prescaler (PR = 0)

	;deal with TCR (timer control register)
	LDR r0, =T0TCR
	LDR r1, [r0]
	
	MOV r2, #0	;handle reserved bits
	MOV r3, #0x3	;enable bit zero for counter enable and holds reset
	
	AND r1, r1, r2	;clear all
	ORR r1, r1, r3	;set bits 0 and 1	
	STR r1, [r0]

	;deal with MCR (match value registers)
	
	;match 0	
	LDR	r0, =T0MR0
	LDR r2, =MATCH0
	STR	r2, [r0]

	;match 1	
	LDR	r0, =T0MR1
	LDR r2, =MATCH1
	STR	r2, [r0]

	;match 2	
	LDR	r0, =T0MR2
	LDR r2, =MATCH2
	STR	r2, [r0]

	;match 3	
	LDR	r0, =T0MR3
	LDR r2, =MATCH3
	STR	r2, [r0]

	;handle T0MCR
	LDR r0, =T0MCR
	LDR r1, [r0]
	MOV r2, #0
	LDR r3, =MATCH_IR
	
	AND r1, r1, r2
	ORR r1, r1, r3
	STR r1, [r0]

	;Let go of reset; start count

	;deal with TCR (timer control register)
	LDR r0, =T0TCR
	LDR r1, [r0]
	
	MOV r3, #0x2	;set reset value to 0 to start clock
	BIC	r1, r1, r3
	STR r1, [r0]

;----------------------------------------------------------
VIC_Setup

	;int enable
	LDR r0, =VICIntEnable
	LDR r1, [r0]
	
	;Set EINT0 to 1
	LDR r2, =TIMER0
	ORR r1, r1, r2
	STR r1, [r0]

	;Select type fo interrupt
	LDR	r0, =VICIntSelect
	LDR r1, [r0]

	;Set EINT0 TO IRQ
	LDR r2, =TIMER0 
	BIC r1, r1, r2
	STR r1, [r0]

	;Silence external interrupt request
	LDR r0, =TIMER0_IR
	LDR r2,=0xF
	STR r2, [r0]


	; *** TASK 3: Vectored IRQ ***


	;Set priority of TIMER0
	LDR r0, =VICVectCntl0
	LDR r1, =0x24		;enable as IRQ and TIMER0
	STR r1, [r0]

	;Set address of TIMER0 interrupt
	LDR r0, =VICVectAddr0
	ADR	r1, ISR_SUB
	STR r1, [r0]
	
	;Clear VICVectAddr 
	LDR r0, =VICVectAddr
	MOV r1, #0
	STR r1, [r0]
	
;-----------------------------------------------------

;Go through each mode and set up the stack: FULL DESCENDING
Stack_Setup

	;SVC mode
	LDR		r0, =SRAM_BASE + SVC_Stack_Size			
	MSR		CPSR_c, #MODE_SVC + I_Bit + F_Bit
	MOV		sp, r0
	
	;FRQ mode
	LDR		r0, =SRAM_BASE + FIQ_Stack_Size	+ SVC_Stack_Size		
	MSR		CPSR_c, #MODE_FIQ + I_Bit + F_Bit
	MOV		sp, r0
	
	;IRQ mode
	LDR		r0, =SRAM_BASE + IRQ_Stack_Size	+ FIQ_Stack_Size + SVC_Stack_Size		
	MSR		CPSR_c, #MODE_IRQ + I_Bit + F_Bit
	MOV		sp, r0

	;Abort mode
	LDR		r0, =SRAM_BASE + ABT_Stack_Size	+ IRQ_Stack_Size + FIQ_Stack_Size + SVC_Stack_Size		
	MSR		CPSR_c, #MODE_ABT+ I_Bit + F_Bit
	MOV		sp, r0	
	
	;Undefined mode
	LDR		r0, =SRAM_BASE + UND_Stack_Size	+ ABT_Stack_Size + IRQ_Stack_Size + FIQ_Stack_Size + SVC_Stack_Size			
	MSR		CPSR_c, #MODE_UND + I_Bit + F_Bit
	MOV		sp, r0	
	
	;System mode
	LDR		r0, =SRAM_BASE + SYS_Stack_Size	+ UND_Stack_Size + ABT_Stack_Size + IRQ_Stack_Size + FIQ_Stack_Size + SVC_Stack_Size			
	MSR		CPSR_c, #MODE_SYS + I_Bit + F_Bit
	MOV		sp, r0
	
	
	;User mode:
	;Set the stack for user mode
	LDR		r0, =SRAM_BASE + USR_Stack_Size	+ SYS_Stack_Size	+ UND_Stack_Size	+ ABT_Stack_Size	+ IRQ_Stack_Size + FIQ_Stack_Size + SVC_Stack_Size			
	
	;Enable interrupts
	MOV		r14, #MODE_USR
	BIC		r14, r14, #(I_Bit + F_Bit)
	MSR		CPSR_c, r14
	
	;leave startup in usercode with interrupts enabled
	LDR		sp, =Stack_Top
	
	B	user_code

;-----------------------------------------------------

;ISR subroutine
ISR_SUB
	
	SUB	LR, LR, #4
	
	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}			;preserve registers

	;look at T0IR
	LDR r2, =TIMER0_IR
	LDR r0, [r2]
	MOV r1, #0xF
	AND r0, r0, r1	;Anding XXXX XXXX we get either 0001,0010,0100,1000
	
	;For Match 0
	MOV r1,	#0x1	
	CMP	r0,	r1
	
	;p0.12 to high
	LDREQ r3, =IO0SET		
	LDREQ r1, =0x1000	
	STREQ r1, [r3]
	
	LDREQ r1, [r2]		;silence intr
	STREQ r1, [r2]
	
	;For Match 1
	MOV r1,	#0x2	
	CMP	r0,	r1
	
	;p1.21 to high
	LDREQ r3, =IO0SET		
	LDREQ r1, =0x200000	
	STREQ r1, [r3]

	LDREQ r1, [r2]		;silence intr
	STREQ r1, [r2]
	
	
	;For Match 2
	MOV r1,	#0x4	
	CMP	r0,	r1
	
	;p0.12 to low
	LDREQ r3, =IO0CLR		
	LDREQ r1, =0x1000	
	STREQ r1, [r3]
	
	LDREQ r1, [r2]		;silence intr
	STREQ r1, [r2]
	
	;For Match 3
	MOV r1,	#0x8	
	CMP r0, r1
	
	;p1.21 to low
	LDREQ r3, =IO0CLR		
	LDREQ r1, =0x200000	
	STREQ r1, [r3]
	
	LDREQ r1, [r2]		;silence intr
	STREQ r1, [r2]
	
	;Clear VICVectAddr again
	LDR r0, =VICVectAddr
	MOV r1, #0
	STR r1, [r0]
	
	
	;Stack stuff
	LDMFD	SP!, {r0-r12, PC}^

;-----------------------------------------------------


	END
