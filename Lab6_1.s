@============================================================================
@ *lab6_1.s*
@ References: http://cas.ee.ic.ac.uk/people/gac1/Architecture/Lecture10_5.pdf
@             https://stackoverflow.com/questions/35756574/how-to-get-an-integer-from-standard-input-in-armsim-without-using-scanf
@             https://www.lri.fr/~de/ARM-Tutorial.pdf
@             https://thinkingeek.com/2013/01/27/arm-assembler-raspberry-pi-chapter-8/
@ Description: (1) Assembly program for searching a given integer number in an
@                  array of integer numbers.
@               - The program must ask the user to enter the number of
@                 elements of the array and accept each element of the array 
@                 through keyboard. 
@               - Also, the user must enter the element to be searched through
@                 keyboard. 
@               - User must pass the array and the searching element as 
@                 parameters to a subroutine, SEARCH.
@               - The program outputs the position of the given element, 
@                 if it is present in the array, otherwise, it outputs -1.
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
@ Logic: (1) Read the three things from user (in form of user inputs)
@            - Array Size
@            - Array Elements (not in sorted order)
@            - Array Element to search. 
@        (2) Read every element of an array (by taking it into register), keep
@            incrementing position counter.
@        (3) Compare with number to be searched. 
@        (4) If equal - stop further check, report position counter.
@        (5) If not equal after all elements are done, then report -1.
@       
@ STDIN and STDOUT are file descripters 0 and 1 respectively.
@------------------------------------------------------------------------------

_PROG_DATA:
.data

    @ Constant Strings.
    FIRST_INPUT_MSG:  .asciz "Please Enter the integer number of array elements (Size < 512): "
    SECOND_INPUT_MSG: .asciz "Please Enter the array elements separated by comma : "
    THIRD_INPUT_MSG:  .asciz "Please Enter the array element to search (only one): "
    OUTPUT_MSG:       .asciz "Input element is found at position : "
    

    .align 2
    STDIN_HANDLE:    .word 0
    STDOUT_HANDLE:   .word 1    
    OUTPUT:          .word -1
    ARR_SIZE:        .word 0
    ARR_ELEM_SEARCH: .word 0    
    ARR:             .skip 0x200  @ For 512 elements
    
      
.text
.align 2
.global _MAIN
.global _END

@ Program starts here
_MAIN: 
        LDR   R9, =OUTPUT
        LDR   R8, =ARR_SIZE
        LDR   R7, =ARR_ELEM_SEARCH
        LDR   R6, =ARR
        MOV   R5, #0                    @ This will be used as counter.
        
        @@@ Read the number of array elements (i.e. size) @@@
        
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =FIRST_INPUT_MSG      @ Read address of FIRST_INPUT_MSG address into R1
        SWI   0x69                      @ Output at console. (Ref. https://www.lri.fr/~de/ARM-Tutorial.pdf)
        
        LDR   R0, =STDIN_HANDLE
        LDR   R0, [R0]
        SWI   0X6c
        
        @@ Check if the input number is greater than 512.
        CMP   R0, #0x200
        BGT   _END
        
        @@ Check if 0 is input or any negative.
        CMP   R0, #0
        BLE  _END
                
        STR   R0, [R8]
        LDR   R8, [R8]
        MOV   R5, R8
        
        
        @@@ Read the array elements @@@
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =SECOND_INPUT_MSG     @ Read address of SECOND_INPUT_MSG address into R1
        SWI   0x69                      @ Output at console. 
       
     ARR_USER_INPUT:
        LDR   R0,  =STDIN_HANDLE
        LDR   R0, [R0]
    
        SWI   0X6c
        
        @ Learnt that by inputting , the ARMSim proceeds. 
        @ Also learnt that characters like space or tab are not accepted for SWI 0x6C. It waits.
        
        STR R0, [R6], #4
        
        SUB   R8, R8, #1
        CMP   R8, #0
        BNE   ARR_USER_INPUT
        
        LDR   R6, =ARR
        
        @ Now, we have two things - array size and array elements.
        
        @@@ Read the array element to search for @@@
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =THIRD_INPUT_MSG      @ Read address of THIRD_INPUT_MSG address into R1
        SWI   0x69                      @ Output at console. 
        
        LDR   R0, =STDIN_HANDLE
        LDR   R0, [R0]
        SWI   0X6c
        
        STR   R0, [R7]
        LDR   R7, [R7]
        MOV   R8, R5
        
        @ At this point, we are ready with information necessary.
        @ Let us call SEARCH
        BL    SEARCH
        
        SUB   R2, R8, R5
        CMP   R8, R2
        BEQ   SHOW_OUTPUT
        ADD   R2, #1
        STR   R2, [R9]
     SHOW_OUTPUT:
        @@@ Show the output @@@
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =OUTPUT_MSG           @ Read address of OUTPUT_MSG address into R1
        SWI   0x69                      @ Output at console.
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, [R9]                  @ Read from OUTPUT address into R1
        SWI   0x6b                      @ Output at console.
        
        B     _END
        
SEARCH:
        STMFD    SP!, {R6, R7, LR}
     SEARCH_LOOP:
        LDR   R0, [R6], #4
        CMP   R0, R7
        BEQ   RET_SEARCH
        SUB   R5, #1
        CMP   R5, #0
        BNE   SEARCH_LOOP
     RET_SEARCH:
        LDMFD    SP!, {R6, R7, PC}
        
        
        
_END:

.end
