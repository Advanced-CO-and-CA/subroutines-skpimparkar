@============================================================================
@ *lab6_1.s*
@ References: http://cas.ee.ic.ac.uk/people/gac1/Architecture/Lecture10_5.pdf
@             https://stackoverflow.com/questions/35756574/how-to-get-an-integer-from-standard-input-in-armsim-without-using-scanf
@             https://www.lri.fr/~de/ARM-Tutorial.pdf
@             https://thinkingeek.com/2013/01/27/arm-assembler-raspberry-pi-chapter-8/
@ Description: (1) Assembly program for searching a given integer number in an
@                  array of sorted integer numbers.
@               - The program must ask the user to enter the number of
@                 elements of the array and accept each element of the array 
@                 through keyboard. 
@               - Also, the user must enter the element to be searched through
@                 keyboard. 
@               - User must pass the array and the searching element as 
@                 parameters to a subroutine SEARCH.
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
@            - Array Elements (descending sorted order)
@            - Array Element to search. 
@        (2) Special Improved Algo.
@            If first element matches element to be searched - declare found.
@            If last  element matches element to be searched - declare found.
@            Find the mid - (first+last)/2 using addresses only.
@            If the mid address does not align it means that we had even elements.
@            In such a case - adjust the mid address by subtracting 2 (word align)
@            Special Improvement: 
@                If the mid address matches min address after adjustment OR
@                mid address matches max address after adjustment - declare not found.
@            Compare element to be searched with mid element. If equal, declare found.
@            Else, if element to be searched is lower than mid, new max = present mid.
@            if element to be searched is higher than mid, new min = present mid.
@            Continue from Find the mid step above again.
@       
@ STDIN and STDOUT are file descripters 0 and 1 respectively.
@
@ NOTE: This algorithm shows efficiency improvement for first and last elements.
@       Also, this does not show higher efficiency than normal binary search 
@       in case the array size is small.
@------------------------------------------------------------------------------

_PROG_DATA:
.data

    @ Constant Strings.
    FIRST_INPUT_MSG:  .asciz "Please Enter the integer number of array elements (Size < 512): "
    SECOND_INPUT_MSG: .asciz "Please Enter the array elements separated by comma : "
    THIRD_INPUT_MSG:  .asciz "Please Enter the array element to search (only one): "
    OUTPUT_MSG:       .asciz "\nInput element is found at position : "
    OUTPUT_MSG_2:     .asciz "\nEfficiency (No. of Searches)  : "

    .align 2
    STDIN_HANDLE:    .word 0
    STDOUT_HANDLE:   .word 1    
    OUTPUT:          .word 0
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

        @@@ Show the output @@@
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =OUTPUT_MSG           @ Read address of OUTPUT_MSG address into R1
        SWI   0x69                      @ Output at console.
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        MOV   R1, R5                    @ Index at which the element is found.
        SWI   0x6b                      @ Output at console.
        
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        LDR   R1, =OUTPUT_MSG_2         @ Read address of OUTPUT_MSG_2 address into R1
        SWI   0x69                      @ Output at console.
        LDR   R0, =STDOUT_HANDLE
        LDR   R0, [R0]
        MOV   R1, R9                    @ Index at which the element is found.
        SWI   0x6b                      @ Output at console.
                
        B     _END
        
SEARCH:
        STMFD    SP!, {R6, R7, R8, LR}  @ R8 is array size.
        @ R0     is Min
        @ R1     is Mid
        @ R2     is Max
        
        MOV      R3, #4
        SUB      R2, R8, #1
        MLA      R2, R2, R3, R6
        LDR      R2, [R2]     @ R2 now contains last element.
        LDR      R0, [R6]     @ R0 contains first element.
        
        LDR      R9, [R9]
        
        @ Check if the element is out of bounds.
        CMP      R7, R2
        BLT      RET_SEARCH_NOT_FOUND
        CMP      R7, R0
        BGT      RET_SEARCH_NOT_FOUND
        
        @ Check if first element is the one.        
        ADD      R9, #1      @ Increment search performance counter.
        CMP      R0, R7
        BEQ      RET_SEARCH  @ We found that element to be searched is first one.
               
        @ Check if last element is the one.
        ADD      R9, #1      @ Increment search performance counter.
        CMP      R2, R7
        BEQ      RET_SEARCH  @ We found that element to be searched is last one.
               
        @ If we are here, it means that we need to search in between first and last.
        @ Now, this code is extra or duplicate but for above checks, it was necessary earlier.
        
    
        MOV      R0, R6
        MOV      R3, #4
        SUB      R2, R8, #1
        MLA      R2, R2, R3, R6

    SEARCH_AGAIN:
	    ADD      R1, R0, R2    @ R1 = first(R6) + last(R2)
        MOV      R1, R1, LSR#1 @ R1 = R1/2 This is effective address of mid.
    ADJUSTED_MID:
        AND      R4, R1, #3
        CMP      R4, #0
        BNE      ADJUST_MID
        
        @ If the mid is same as either min or max, then no point in proceeding.
        @ It means that we have exhausted the array elements. Declare not found.
        CMP      R1, R0
        BEQ      RET_SEARCH_NOT_FOUND
        CMP      R1, R2
        BEQ      RET_SEARCH_NOT_FOUND
        
        ADD      R9, #1        @ Increment search performance counter.
        LDR      R3, [R1]
        CMP      R3, R7
        BEQ      RET_SEARCH
        BLT      SEARCH_TOWARDS_FIRST_HALF
        
        MOV      R0, R1        @ Now, mid is new max.
        B        SEARCH_AGAIN
        
    SEARCH_TOWARDS_FIRST_HALF:
        MOV      R2, R1        @ Now, mid is new min.
        B        SEARCH_AGAIN
        
    ADJUST_MID:
        SUB      R1, R1, #2
        B        ADJUSTED_MID
        
    RET_SEARCH_NOT_FOUND:
        MOV      R5, #-1
        LDMFD    SP!, {R6, R7, R8, PC}

     RET_SEARCH:
        SUB      R5, R2, R6
        MOV      R5, R5, LSR#2  @This is going to be the index at which the element in an array is found.
        LDMFD    SP!, {R6, R7, R8, PC}
               
_END:

.end
