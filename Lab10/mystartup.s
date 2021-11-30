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

;-----------------------------------------------------------------------------
;Stack stuff
SRAM_BASE		EQU	0x40000000	
	
USR_Stack_Size	EQU	0x100						
FIQ_Stack_Size	EQU	0x200
IRQ_Stack_Size	EQU	0x300
SVC_Stack_Size	EQU	0x400
ABT_Stack_Size	EQU	0x500
UND_Stack_Size	EQU	0x600
;SYS_Stack_Size	EQU	0x700		
	
;------------------------------------------------------------------------------
;External Interrupt Stuff
PINSEL1	EQU	0xE002C004
IO0DIR	EQU	0xE0028000
	
;EINT Address 
EXTINT 		EQU 	0xE01FC140	;address for EINTX
EXTMODE		EQU 	0xE01FC148	;address for level / edge
EXTPOLAR	EQU		0xE01FC14C	;address for rising /trailing
EINT0		EQU		0x4000
	
;------------------------------------------------------------------------------
;VIC Stuff
VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010	
VICIntEnClear	EQU	0xFFFFF014
	
;------------------------------------------------------------------------------
;masks for LEDS task
LED_ALL	EQU	0xFF00	 
LED_ALT	EQU	0xAA00
LED_FOUR EQU 0x0F00
;------------------------------------------------------------------------------	

	GLOBAL ISR_SUB

	IMPORT user_code
	IMPORT LEDs
	IMPORT lcd_subs
	IMPORT DELAY
	IMPORT LED_delay
	IMPORT EINT
		
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
	LDR	PC,IRQ_Addr		;LDR PC, [PC, #-0x0FF0]	vectored interrupt
	LDR	PC,FIQ_Addr

Reset_Addr	DCD	Reset_Handler
Undef_Addr	DCD	UndefHandler
SWI_Addr	DCD	SWIHandler			;SWI interrupt
PAbt_Addr	DCD	PAbtHandler
DAbt_Addr	DCD	DAbtHandler
		DCD	0
IRQ_Addr	DCD	IRQHandler		
FIQ_Addr	DCD	FIQHandler
	
PAbtHandler	B	PAbtHandler
DAbtHandler	B	DAbtHandler
IRQHandler	B	ISR_SUB				;IRQ interrupt
FIQHandler	B	FIQHandler
UndefHandler	B	UndefHandler

;-----------------------------------------------------
;Initialize MAM to run at one clock cycle instead of seven. Then, branch to main code.	
Reset_Handler

;Memory accelerator
MAM

	LDR r1,=MAMCR
	MOV R0, #0x0
	STR R0, [R1]
	LDR R2,=MAMTIM
	MOV R0,#0x1
	STR R0,[R2]
	MOV R0,#0x2
	STR R0,[R1]
	
;Go through each mode and set up the stack: FULL DESCENDING
Stack_Setup

	;SVC mode		
	MSR		CPSR_c, #MODE_SVC + I_Bit + F_Bit
	LDR		sp, =SRAM_BASE + SVC_Stack_Size	
	
	;FRQ mode 	
	MSR		CPSR_c, #MODE_FIQ + I_Bit + F_Bit
	LDR		sp, =SRAM_BASE + FIQ_Stack_Size		
	
	;IRQ mode	
	MSR		CPSR_c, #MODE_IRQ + I_Bit + F_Bit
	LDR		sp, =SRAM_BASE + IRQ_Stack_Size	

	;Abort mode		
	MSR		CPSR_c, #MODE_ABT + I_Bit + F_Bit
	LDR		sp, =SRAM_BASE + ABT_Stack_Size	
	
	;Undefined mode		
	MSR		CPSR_c, #MODE_UND + I_Bit + F_Bit
	LDR		sp, =SRAM_BASE + UND_Stack_Size	
	
	;System mode		
	;MSR		CPSR_c, #MODE_SYS + I_Bit + F_Bit
	;LDR		sp, =SRAM_BASE + SYS_Stack_Size 
	
	;User mode: Set the stack for user mode then enable interrupts				
	MOV		r14, #MODE_USR
	BIC		r14, r14, #(I_Bit + F_Bit)
	MSR		CPSR_c, r14
	
	;leave startup in usercode with interrupts enabled
	LDR		sp, =SRAM_BASE + USR_Stack_Size
	LDR		PC, =EINT
	;LDR		PC, =user_code
	
	B DONE

;-----------------------------------------------------

;Software Interrupt subroutine
SWIHandler

	;**Stack stuff
	STMFD	SP!, {r0 - r12, LR}		;preserve registers
	
	;Determine SWI type
	LDR	r0, [LR,#-4] 
	LDR r1, =0xFFFFFF
	AND r0, r0, r1
	
	;Light up all pins
	CMP 	r0, #1
	LDREQ	r4, =LED_ALL
	BLEQ	LEDs 
	
	;Light up alternating pins
	CMP 	r0, #2
	LDREQ	r4, =LED_ALT
	BLEQ LEDs
	
	CMP 	r0, #3
	BLEQ lcd_subs
	
	;Stack stuff
	LDMFD	SP!, {r0 - r12, PC}	

;-----------------------------------------------------

;ISR subroutine
ISR_SUB
	
	SUBS LR, LR, #4
	
	STMFD	SP!, {r0 - r12, LR}		;preserve registers	
	
	BL	LED_delay
	
	LDR r4, =LED_ALT
	BL LEDs
	
	BL	LED_delay
	
	;Silence interrupt
	MOV r0, #0x8
	LDR r1, =EXTINT
	LDR r2, [r1]
	ORR r2, r2, r0
	STR	r2, [r1]
	
	;Stack stuff
	LDMFD	SP!, {r0-r12, PC}^

	;LDMFD	SP!, {r0-r12,LR}
	;SUBS	PC, LR, #4

DONE	

stop B stop

	END