
.data                                           // must be delcared to call scanf()
n:      .word 0                                 // must be delcared to call scanf()

.text
prompt:         .string "Please specify N: "
scan:           .string "%d"                    // holds user input in integer
msg:    	.string "The 2D array is: {"
printX:		.string "The X matrix is: {"
printY:		.string "The Y matrix is: {"
printNum:	.string "%d"
middle:		.string ", "
ending:		.string "}\n"
indexing:	.string "(%d,%d)"

define(userInput,x19)
define(arr_base, x20)
define(offset, x21)
define(alloc, x22)
define(numOfElements, x23)
define(counter, x24)
define(xOrY, x25)
define(matrix, x26)
define(randNum, x27)
define(arr_size, x28)

.balign 4
.global main

main:   stp x29, x30, [sp, -16]!
        mov x29, sp

        ldr x0,=prompt
        bl printf

        ldr x0, =scan                           // scan user input
        ldr x1, =n                              // load  address =n to register x1
        bl scanf                                // Get the first number

        ldr x14, =n                              // load address =n to register x14
        ldr userInput, [x14]                     // load the value of n

        mul arr_size, userInput, userInput 	// determine size of arr
	mov x9, 8				// integer is 4 bytes
        mul alloc, arr_size, x9 		// total array size
        neg alloc, alloc
	and alloc, alloc, -16                   // allocates (N*N*4) & -16 bytes
        add sp, sp, alloc

        mov arr_base, sp
        mov offset, 0
        mov counter, 0
	mov x11, 2	
	mul numOfElements, arr_size, x11	

        mov x0, 0
        bl time
        bl srand
	
	ldr x0, =msg				
	bl printf

strLoop:
	bl rand

	mov x10, x0	
	mov x11, 25			 // putting 25 into x9 temp register
	lsr x10, x10, x11 	         // logic shift right to make randomly generated number small
	add x10, x10, 1                  // ensuring jackpot number is never 0 or the loop will exit
	
	str x10, [arr_base, offset]	
	add offset, offset, 4 

	add counter, counter, 1

strLoopTest:
	cmp counter, numOfElements 
	b.lt strLoop
	
	mov counter, 1
	mov offset, 0

ldrLoop:
	ldr x10, [arr_base, offset]
	add offset, offset, 4 
	ldr x11, [arr_base, offset]
	add offset, offset, 4 

	ldr x0, =indexing
	mov x1, x10
	mov x2, x11
	bl printf
	
	ldr x0, =middle
	bl printf

	add counter, counter, 1
	
//	add j, j , 1	
//	cmp j, userInput
//	b.lt ldrLoopTest
//	mov j , 0
//	add i, i , 1

//findOffset:
//	mul x12, userInput, i
//	add x12, x12, j
//	mul x12, x12, x9
	

ldrLoopTest:
	cmp counter, arr_size
	b.lt ldrLoop

	ldr x10, [arr_base, offset]
	add offset, offset, 4 
	ldr x11, [arr_base, offset]
	add offset, offset, 4 

	ldr x0, =indexing		// printing index of last element in 3D array
	mov x1, x10
	mov x2, x11
	bl printf

	ldr x0, =ending			// printing closing bracket
	bl printf
	
	mov counter, 1
	mov offset, 0
	mov xOrY, 0

printXMatrix:
	ldr x0, =printX
	bl printf
	b displayXY
	
printYMatrix:
	add xOrY, xOrY, 1
	ldr x0, =printY
	bl printf
	
displayXY:
	ldr x10, [arr_base, offset]
	add offset, offset, 8 
	
	ldr x0, =printNum
	mov x1, x10
	bl printf
	
	ldr x0, =middle
	bl printf
	
	add counter, counter, 1

displayXYTest:
	cmp counter, arr_size
	b.lt displayXY
	
	ldr x10, [arr_base, offset]
	add offset, offset, 8 
	
	ldr x0, =printNum		//printing martix num
	mov x1, x10
	bl printf
	
	ldr x0, =ending			// printing closing bracket
	bl printf

	mov counter, 1
	mov offset, 4
	
	
	cmp xOrY, 1
	b.lt printYMatrix

	mov counter,1
	mov offset, 0

XYMultiply:
	




	
end:	sub sp, sp, alloc
        ldp x29, x30, [sp], 16                     //TODO fix
        ret


