// CPSC 355 Assign4
// Jada Li
// UCID: 30016807

.text
msg:    	.string "The 2D array is: {"
printX:		.string "The X matrix is: {"
printY:		.string "The Y matrix is: {"
printNum:	.string "%d"
middle:		.string ", "
ending:		.string "}\n"
indexing:	.string "(%d,%d)"
printProduct:	.string "The product matrix is: {"

define(userInput,x19)
define(arr_base, x20)
define(offset, x21)
define(alloc, x22)
define(counter, x24)
define(i, x25)
define(productarr_base, x26)
define(j, x27)
//define(arr_size, x28)

//define(baseAddress, x20)
//	arr_base = 0
//	productarr_base = 4
//	baseAddress_size = 8



.balign 4
.global main

main:   stp x29, x30, [sp, -16]!
        mov x29, sp

	mov x9, x1
	ldr x0, [x9, 8]			// 8 byte offset to account for the program name
	bl atoi
	mov userInput, x0

        mul x28, userInput, userInput 	// determine size of arr
	mov x9, 8				// integer is 4 bytes
        mul alloc, x28, x9 		// total array size
        neg alloc, alloc
	and alloc, alloc, -16                   // allocates (N*N*4) & -16 bytes
        add sp, sp, alloc

	mov arr_base, sp
        mov offset, 0
        mov counter, 0
	mov x11, 2	
	mul x23, x28, x11			// calculating number of elements in array

        mov x0, 0
        bl time
        bl srand
	
	ldr x0, =msg				
	bl printf

strLoop:
	bl rand

	mov x10, x0	
	mov x11, 25			 // putting 25 into x11 temp register
	lsr x10, x10, x11 	         // logic shift right to make randomly generated number small
	add x10, x10, 1                  // ensuring jackpot number is never 0 or the loop will exit
	
	str x10, [arr_base, offset]	
	add offset, offset, 4 

	add counter, counter, 1

strLoopTest:
	cmp counter, x23		// compare to number of elements in array 
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
	
ldrLoopTest:
	cmp counter, x28
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
	mov x23, 0			//TODO using i as tempVar for now

printXMatrix:
	ldr x0, =printX
	bl printf
	b displayXY
	
printYMatrix:
	add x23, x23, 1			//TODO using i as tempVar for now
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
	cmp counter, x28
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
	
	cmp x23, 1			//TODO using i as tmpVar for now
	b.lt printYMatrix

XYMultiply:
	add sp, sp, alloc			// allocating space for product matrix

	mov productarr_base, sp			
        mov offset, 0
	mov counter, 0
	mov i, 0		// product matrix row
	mov j, 0		// product matrix column
	mov x10, 0		//
	mov x11, 0		// 
	mov x23, 0		//TODO k
	mov x28, 0	

findXMatrixOffset:				// LOOP
	mov x9, 8 				// bytes between 2D array elements
	
	mov offset, userInput			// m
	mul offset, offset, i			// m * i
	add offset, offset, x23			// (m * i) + j
	mul offset, offset, x9			// ((m * i) + j) * E_size
	ldr x10, [arr_base, offset]

findYMatrixOffset:				// LOOP
	mov x9, 8 				// bytes between 2D array elements
	mov x12, 4				// offset for y matrix elements	

	mov offset, userInput			// m
	mul offset, offset, x23			// (m * i)
	add offset, offset, j			// ((m * i) + j) * E_size
	mul offset, offset, x9			// ((m * i) + j) * E_size
	add offset, offset, x12			// +4 bytes to get to y matrix values
	ldr x11, [arr_base,offset]		// getting Y element

calculateProduct:					
	mul x10, x10, x11			// multiplying X and Y element
	add x28, x28, x10			// summing

	add x23, x23, 1				// increment column for X matrix and row for Y matrix
	cmp x23, userInput
	b.lt findXMatrixOffset
	
	mov offset, 0
	mov x9, 8				// bytes between 2D array elements
	mul offset, counter, x9			// finding offset for elements in product matrix

	str x28, [productarr_base, offset]	// storing product TODO FIX OFFSET
	add counter, counter,  1

YMatrixTest:					// LOOP TEST
	mov x28, 0
	mov x23, 0				// resetting column for X matrix and row for Y matrix
	add j, j, 1				// incrementing	column for Y matrix
	cmp j, userInput			// check if finished calculating product element
	b.lt findXMatrixOffset

XMartixTest:
	mov x28, 0
	mov x23, 0
	mov j, 0
	add i, i , 1				// incrementing row for X matrix
	cmp i, userInput
	b.lt findXMatrixOffset

	mov counter, 1
	mov offset, 0
	mul x28, userInput, userInput 	// determine size of arr
printProductMatrix:
	ldr x0, =printProduct
	bl printf
	
ProductMatrix:
	ldr x10, [productarr_base, offset]
	add offset, offset, 8 
	
	ldr x0, =printNum
	mov x1, x10
	bl printf
	
	ldr x0, =middle
	bl printf
	
	add counter, counter, 1

	cmp counter, x28
	b.lt ProductMatrix
	
	ldr x10,[productarr_base, offset]
	add offset, offset, 8 
	
	ldr x0, =printNum		//printing martix num
	mov x1, x10
	bl printf
	
	ldr x0, =ending			// printing closing bracket
	bl printf

	mov counter,1
	mov offset, 0













end:	sub sp, sp, alloc			
	sub sp, sp, alloc
        ldp x29, x30, [sp], 16
        ret


