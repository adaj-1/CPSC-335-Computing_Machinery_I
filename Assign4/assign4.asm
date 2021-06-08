// CPSC 355 Assign4
// Jada Li
// UCID: 30016807

.text
printInputInvalid:.string "Please input N value > 0\n"
print2DArray:  	.string "The 2D array is: {"
printX:		.string "The X matrix is: {"
printY:		.string "The Y matrix is: {"
printNum:	.string "%d"
middle:		.string ", "
ending:		.string "}\n"
indexing:	.string "(%d,%d)"
printProduct:	.string "The product matrix is: {"
printSum:	.string "The sum is: %ld\n"
printMax:	.string "The max is: %ld\n"
printMin:	.string "The min is: %ld\n"
printTest:	.string "%ld\n"

define(userInput,x19)
define(arr_base, x20)
define(productarr_base, x21)
define(alloc, x22)
define(offset, x23)
define(counter, x24)
define(i, x25)
define(k, x26)
define(j, x27)
define(tmp, x28)

define(sumMaxMin_base, x19)
define(element, x15)

.balign 4				// ensures instructions are properly aligned
.global main				// makes the label "main" visible to the linker

main:   stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
        mov x29, sp			// updates FP to the current SP

	mov x9, x1			// getting command line input
	ldr x0, [x9, 8]			// 8 byte offset to account for the program name
	bl atoi				// converting string to integer
	mov userInput, x0		// userInput holds N
	
	cmp userInput, xzr
	b.gt setupArray			

	ldr x0, =  printInputInvalid
	bl printf
	b  end

setupArray:
	mul tmp, userInput, userInput 	// set tmp to size of arr (N*N)

	mov x9, 2			// hold 2 to calculate num of elements
	mul tmp, tmp, x9		// calculate num of elements in 2D array 2*(N*N)
	mov x9, 8			// byte allocation for each integers
	mul alloc, tmp, x9 		// integer is 8 bytes and x y matrix stored together so 16 bytes
        neg alloc, alloc		// to deallocate at the end
	and alloc, alloc, -16           // allocates (N*N*4) & -16 bytes
       
	add sp, sp, alloc		// update stack frame
	mov arr_base, sp		// set array base to stack frame
        
	add sp, sp, alloc		// allocating space for product matrix
	mov productarr_base, sp		// setting base for prodcut array	
	
	add sp, sp, -16		// allocating space for product matrix
//	mov sumMaxMin_base, sp		// setting base for prodcut array	
	
	mov offset, 0			// initialize offset
        mov counter, 0			// initialize counter
	
	mov x0, 0			// initalizing x0 to 0
        bl time				// using time to set random seed
       // bl srand	TODO  remove comment		// set the seed for random
	
	ldr x0, =print2DArray		// begin displaying randomly generated 2D array				
	bl printf			// print message

// fills 2D array with random integers
strLoop:
	bl rand				// call random 

	mov x9, x0			// x9 holds random integer
	mov x10, 25			// used to populate with integers less than or equal to 100
	lsr x9, x9, x10 	        // logic shift right to make randomly generated number small
	add x9, x9, 1                   // ensurng num is never 0 
	
	str x9, [arr_base, offset]	// store in 2D array
	add offset, offset, 8 		// increment offset

	add counter, counter, 1		// increment counter

strLoopTest:
	cmp counter, tmp	//TODO		// compare to number of elements in array 
	b.lt strLoop			// loop until 2D array is filled
	
	mov x9, 2			// used to calculate size of array
	udiv tmp, tmp, x9		// setting back to size of array
	mov counter, 1			// reset counter
	mov offset, 0			// reset offset

ldrLoop:
	ldr x9, [arr_base, offset]	// load x matrix value
	add offset, offset, 8 		// increment offset
	ldr x10, [arr_base, offset]	// load y matrix value
	add offset, offset, 8 		// increment offset

	ldr x0, =indexing		// print 2D array
	mov x1, x9			// x element
	mov x2, x10			// y element
	bl printf			// print message
	
	ldr x0, =middle			// print comma
	bl printf			// print message

	add counter, counter, 1		// increment counter
	
ldrLoopTest:
	cmp counter, tmp		// compare to N*N
	b.lt ldrLoop			// loop until num of elements - 1 is printed

	ldr x9, [arr_base, offset]	// load x matrix value
	add offset, offset, 8 		// increment offset
	ldr x10, [arr_base, offset]	// load y matrix value
	add offset, offset, 8 		// increment offset

	ldr x0, =indexing		// printing index of last element in 2D array
	mov x1, x9			// load x matrix value
	mov x2, x10			// load y matrix value
	bl printf			// print message

	ldr x0, =ending			// printing closing bracket
	bl printf			// print message
	
	mov counter, 1			// reset counter
	mov offset, 0			// reset offset
	mov i, 0			// initialize loop counter

printXMatrix:
	ldr x0, =printX			// begin printing X matrix
	bl printf			// print message
	b displayXY			// branch to print X matrix
	
printYMatrix:
	add i, i, 1			// count second loop
	mov counter, 1			// reset counter
	mov offset, 8			// set offset to y matrix

	ldr x0, =printY			// begin printing Y matrix
	bl printf			// print message
	
displayXY:
	ldr x9, [arr_base, offset]	// loading first element
	add offset, offset, 16 		// increment offset by 8 to get to next matrix element
	
	ldr x0, =printNum		// print matrix element
	mov x1, x9			// load matrix element value
	bl printf			// print message
	
	ldr x0, =middle			// print comma
	bl printf			// print message
	
	add counter, counter, 1		// increment counter 

displayXYTest:
	cmp counter, tmp		// check if all matrix elements printed
	b.lt displayXY			// loop until num of elements - 1 is printed
	
	ldr x9, [arr_base, offset]	// load last element 
	
	ldr x0, =printNum		// printing matrix element
	mov x1, x9			// load matrix element value
	bl printf			// print message	
	
	ldr x0, =ending			// print closing bracket
	bl printf			// print message

	cmp i, 1			// check if loop printed both X Y matrix
	b.lt printYMatrix		// loop until complete
        mov offset, 0			// reset offset
	mov counter, 0			// reset counter

XYMultiply:
	mov i, 0			// product matrix row counter
	mov j, 0			// product matrix column counter
	mov k, 0			// product matrix internal loop counter
	mov x13, 0	//TODO

findXMatrixOffset:			// LOOP
	mov x9, 16 			// bytes between 2D array elements
	
	mov offset, userInput		// m
	mul offset, offset, i		// m * i
	add offset, offset, k		// (m * i) + j
	mul offset, offset, x9		// ((m * i) + j) * E_size
	ldr x10, [arr_base, offset]	// load X element

findYMatrixOffset:			// LOOP
	mov x9, 16 			// bytes between 2D array elements
	mov x12, 8			// offset for y matrix elements	

	mov offset, userInput		// m
	mul offset, offset, k		// (m * i)
	add offset, offset, j		// ((m * i) + j) * E_size
	mul offset, offset, x9		// ((m * i) + j) * E_size
	add offset, offset, x12		// +4 bytes to get to y matrix values
	ldr x11, [arr_base,offset]	// load Y element

calculateProduct:					
	mul x10, x10, x11		// multiplying X and Y element
	add x13, x13, x10		// summation

	add k, k, 1			// increment column for X matrix and row for Y matrix
	cmp k, userInput		// check if calculation is complete for row/column
	b.lt findXMatrixOffset		// loop until complete
	
	mov offset, 0			// reset offset
	mov x9, 16			// bytes between 2D array elements
	mul offset, counter, x9		// finding offset for elements in product matrix

	str x13, [productarr_base, offset]	// storing product in new array
	add counter, counter,  1	// indicate that an element has been calculated

YMatrixTest:				// LOOP TEST
	mov x13, 0			// reset for next product calculation
	mov k, 0			// reset column for X matrix and row for Y matrix
	add j, j, 1			// incrementing	column for Y matrix
	cmp j, userInput		// check if finished calculating column product element
	b.lt findXMatrixOffset		// loop until complete

XMartixTest:
	mov x13, 0			// reset for next product calculation
	mov k, 0			// reset column for X matrix and row for Y matrix
	mov j, 0			// reset row for Y matrix
	add i, i , 1			// incrementing row for X matrix
	cmp i, userInput		// check if finisshed calculating row product element
	b.lt findXMatrixOffset		// loop until complete

	mov counter, 1			// reset counter
	mov offset, 0			// reset offset

printProductMatrix:
	ldr x0, =printProduct		// print product matrix
	bl printf			// print message
	
ProductMatrix:
	ldr x9, [productarr_base, offset]	// load product matrix element
	add offset, offset, 16 		// update offset to next prodct matrix element
	
	ldr x0, =printNum		// print product matrix element
	mov x1, x9			// load product matrix element
	bl printf			// print message

	ldr x0, =middle			// print comma between elements
	bl printf			// print message
	
	add counter, counter, 1		// indicate how many elements have been printed

	cmp counter, tmp		// check if all elements-1  have been printed
	b.lt ProductMatrix		// loop until complete
	
	ldr x9,[productarr_base, offset]	// load last product matrix element
					
	ldr x0, =printNum		// print last element in product matrix
	mov x1, x9			// load last element
	bl printf			// print message
	
	ldr x0, =ending			// printing closing bracket
	bl printf			// print message
	
	mov counter, 0			// reset counter
	mov offset, 0			// reset offset

//	b end

sumMaxMin:
	ldr element, [productarr_base, offset]
	add offset, offset, 16

	mov i , 0 			// sum
	mov j, element		// max
	mov k, element			// min
//TODO store in struct
sum:
	add counter, counter, 1
	add i, i, element

max:	
	cmp j, element
	b.ge min
	mov j, element

min:	
	cmp k, element
	b.le sumMaxMinTest		//TODO display summary structure
	mov k, element

sumMaxMinTest:
	ldr element, [productarr_base, offset]
	add offset, offset, 16
	cmp counter, tmp                //cmp to size of arr
	b.lt sum

	ldr x0, =printSum
	mov x1, i
	bl printf
	
	ldr x0, =printMax
	mov x1, j
	bl  printf

	ldr x0, =printMin
	mov x1, k
	bl printf	
	b end

end:	sub sp, sp, -16			
	sub sp, sp, alloc			
	sub sp, sp, alloc
        ldp x29, x30, [sp], 16
        ret


