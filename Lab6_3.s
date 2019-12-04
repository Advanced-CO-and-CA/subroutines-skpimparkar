@============================================================================
@ *lab6_1.s*
@ References: http://cas.ee.ic.ac.uk/people/gac1/Architecture/Lecture10_5.pdf
@             https://stackoverflow.com/questions/35756574/how-to-get-an-integer-from-standard-input-in-armsim-without-using-scanf
@             https://www.lri.fr/~de/ARM-Tutorial.pdf
@             https://thinkingeek.com/2013/01/27/arm-assembler-raspberry-pi-chapter-8/
@ Description: (1) An assembly language program that accepts an integer number, 
@                  N, through keyboard and computes the Nth Fibonacci number 
@                  in recursive way.
@============================================================================
@============================================================================
@
@ EDIT HISTORY FOR MODULE
@
@ $Header: $
@ Guide: Prof. Madhumutyam IITM, PACE
@
@ when          who                    what, where, why
@ -----------   -------------------    --------------------------
@ 4 Dec 2019    Swapneel Pimparkar     (Bengaluru) First Draft
@============================================================================

@------------------------------------------------------------------------------
@ Logic: for subroutine fibbonacci
@        if input number is zero then return 0
@        if input number is one then return 1 else 
@        return fibbonacci(n-1) + fibbonacci(n-2)
@
@------------------------------------------------------------------------------
_PROG_DATA:
.data

    @ Constant Strings.
    INPUT_MSG:        .asciz "Please Enter the integer to find fibonacci (>2 and <1024): "
    OUTPUT_MSG:       .asciz "Fibonacci Number for input integer : "
    ERR_MSG:          .asciz "\nInput Error! Terminating!\n"

    .align 2
    STDIN_HANDLE:    .word 0
    STDOUT_HANDLE:   .word 1    
    OUTPUT_F_N:      .word 0
    INPUT_N:         .word 0

.text
.align 2
.global _MAIN
.global _END

@ Program starts here
_MAIN: 
        LDR   R9, =OUTPUT_F_N
        LDR   R8, =INPUT_N
        
        @@@ Read the number @@@
        
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =INPUT_MSG            @ Read address of INPUT_MSG address into R1
        SWI   0x69                      @ Output at console. (Ref. https://www.lri.fr/~de/ARM-Tutorial.pdf)
        
        LDR   R0, =STDIN_HANDLE
        LDR   R0, [R0]
        SWI   0X6c
        
        @@ Check if the input number is greater than 1024.
        CMP   R0, #0x400
        BGT   _ERR
        
        @@ Check if 0 or 1 is input or any negative.
        CMP   R0, #1
        BLE  _ERR
        
        STR  R0, [R8]                   @ Store the input number.
        LDR  R8, [R8]
        
        BL   FIBONACCI
        
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =OUTPUT_MSG           @ Read address of OUTPUT_MSG address into R1
        SWI   0x69                      @ Output at console.
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        MOV   R1, R3                    @ FIBONACCI number.
        STR   R3, [R9]
        SWI   0x6b                      @ Output at console.
        
        B     _END
               
FIBONACCI:

	STMFD	SP!, {R4, R8, LR}
    
	ADD	R8, SP, #8
	SUB	SP, SP, #12
    
	STR	R0, [R8, #-16]
	LDR	R3, [R8, #-16]
    
	CMP	R3, #0                  @ Check if input number is zero.
    
	BNE	CHECK_N_EQUAL_TO_1      @ if not zero then check if it is equal to 1
    
	MOV	R3, #0                  @ Output is zero.
    
	B	GO_UNWIND
    
CHECK_N_EQUAL_TO_1:
	LDR	R3, [R8, #-16]
	CMP	R3, #1                  @ Check if input number is 1.
	
    BNE	GO_RECURSIVE            @ If not equal to 1 then call fibbonacci in recursive way.
	MOV	R3, #1                  @ Output is 1.
	B	GO_UNWIND               @ Unwind the stack (from recursion) if any.
    
GO_RECURSIVE:
	LDR	R3, [R8, #-16]          
	SUB	R3, R3, #1              @ This is essentially (n-1)
	MOV	R0, R3
	BL	FIBONACCI               @ Call fibbonacci with (n-1)
	MOV	R4, R0
    MOV R4, R3
	LDR	R3, [R8, #-16]
	SUB	R3, R3, #2              @ This is essentially (n-2)
	MOV	R0, R3
	BL	FIBONACCI               @ Call fibbonacci with (n-2)
	@MOV	R3, R0
	ADD	R3, R4, R3              @ Add numbers.
    
GO_UNWIND:
	SUB	SP, R8, #8
	LDMFD	SP!, {R4, R8, LR}
	BX	LR        
        
_ERR:
    LDR   R0, =STDOUT_HANDLE
    LDR   R0, [R0]
    LDR   R1, =ERR_MSG           @ Read address of ERR_MSG address into R1
    SWI   0x69                   @ Output at console.
    
_END:    
    .end        
        