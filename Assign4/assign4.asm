// CPSC 355 Assign4
// Jada Li
// UCID: 30016807
.text
printInputInvalid:.string "Please input N value > 0\n"	// indicates to  user that input iss invalid
print2DArray:  	.string "The 2D array is: {"		// begins printing 2D array
printX:		.string "The X matrix is: {"		// brgins printing X array
printY:		.string "The Y matrix is: {"		// begins printing Y array
printNum:	.string "%d"				// prints matrix values
middle:		.string ", "				// used to separate matrix values
ending:		.string "}\n"				// prints end of array
indexing:	.string "(%d,%d)"			// indexing format for 2D array
printProduct:	.string "The product matrix is: {"	// begins printing product matrix
printSum:	.string "The sum is: %d\n"		// prints sum value
printMax:	.string "The max is: %d\n"		// prints min value
printMin:	.string "The min is: %d\n"		// prints min value

define(userInput,x19)			// holds comman line input N value
define(arr_base, x20)			// 2D array (x, y) base address 
define(productarr_base, x21)		// holds product array base addres
define(alloc, x22)			// holds amount of bytes to allocate
define(offset, x23)			// used to calculate offsets in stack
define(counter, x24)			// used to keep track of loops and elements
define(i, x25)				// used to keep track of loops and elements
define(k, x26)				// used to keep track of loops
define(j, x27)				// used to keep track of loops
define(sizeOfArr, x28)			// used to hold total size of array

define(element, x15)			// used to calculated sum max and min of product matrix

.balign 4				// ensures instructions are properly aligned
.global main				// makes the label "main" visible to the linker

main:   stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
        mov x29, sp			// updates FP to the current SP

	mov x9, x1			// getting command line input
	ldr x0, [x9, 8]			// 8 byte offset to account for the program name
	bl atoi				// converting string to integer
	mov userInput, x0		// userInput holds N
	
        // TODO - check of no command line input
	cmp userInput, xzr		// to ensure valid input
	b.gt setupArray			// if valid dont end

	ldr x0, =  printInputInvalid	// display invalid input
	bl printf			// print statement
	b  end				// exit program

// set up 2D array to hold X and Y matrix
setupArray:
	// calculate stack size required for:
	//   struct {Sum, Max, Min); (X,Y) Matrix, and Product Matrix
	mul sizeOfArr, userInput, userInput 	// set tmp to size of arr (N*N)
	mov x9, 24 			// allocate x,y and product array with 8 byte int i.e. 3*8=24 
	mul alloc, sizeOfArr, x9	// 3*8*N*N		
	
	add alloc, alloc, 24		// add local valuable struct{ sum, max, min )

	neg alloc, alloc		// to deallocate at the end
	and alloc, alloc, -16           // allocates 3*(N*N*8) & -16 bytes
	add sp, sp, alloc		// update stack pointer

	struct_Sum_offset = 0		// offset from sp
	struct_Max_offset = 8		// offset for Max
	struct_Min_offset = 16		// offset for Min

	add arr_base, sp, 24		// skip sum, max & min
	
	mov x9, 16			// calc x,y matrix/array size for productarr base i.e. 2*8*N*N
	mul x10, sizeOfArr, x9		// calculating bytes needed for product Matrix
	add productarr_base, arr_base, x10	// setting product array base

	// setup to fill x,y array with random value
	mov x9, 2			// to calculate size  of X Y matrix
	mul sizeOfArr, sizeOfArr, x9	// *2 to account for x & y values
	mov offset, 0			// initialize offset
        mov counter, 0			// initialize counter
	
	mov x0, 0			// initalizing x0 to 0
        bl time				// using time to set random seed
        bl srand			// set the seed for random
	
	ldr x0, =print2DArray		// begin displaying randomly generated 2D array				
	bl printf			// print message


// store loop for 2D array with random integers
strLoop:
	bl rand				// call random 

	mov x9, x0			// x9 holds random integer
	mov x10, 100			// used to find random integers less than or equal to 100
	and x9,x9, x10			// calculating random number less than or equal to 100
	str x9, [arr_base, offset]	// store in 2D array
	add offset, offset, 8 		// increment offset

	add counter, counter, 1		// increment counter

// checking if finished storing every element
strLoopTest:
	cmp counter,sizeOfArr		// compare to number of elements in array 
	b.lt strLoop			// loop until 2D array is filled
	
	mov x9, 2			// used to calculate size of array
	udiv sizeOfArr, sizeOfArr, x9   // setting back to size of array
	mov counter, 1			// reset counter
	mov offset, 0			// reset offset

// loading 2D array of X and Y matrix to print
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

// checking if finished printing num of elements - 1	
ldrLoopTest:
	cmp counter, sizeOfArr		// compare to N*N
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


// begin printing X Matrix
printXMatrix:
	ldr x0, =printX			// begin printing X matrix
	bl printf			// print message
	b displayXY			// branch to print X matrix

// begin printing Y Matrix
printYMatrix:
	add i, i, 1			// count second loop
	mov counter, 1			// reset counter
	mov offset, 8			// set offset to y matrix

	ldr x0, =printY			// begin printing Y matrix
	bl printf			// print message

// load and print elements in X and Y matrix
displayXY:
	ldr x9, [arr_base, offset]	// loading first element
	add offset, offset, 16 		// increment offset by 8 to get to next matrix element
	
	ldr x0, =printNum		// print matrix element
	mov x1, x9			// load matrix element value
	bl printf			// print message
	
	ldr x0, =middle			// print comma
	bl printf			// print message
	
	add counter, counter, 1		// increment counter 

// checks if on last element of array to finish printing
displayXYTest:
	cmp counter, sizeOfArr		// check if all matrix elements printed
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

// Matrix multiplication:
//  int i, j, k;
//      for (i = 0; i < N; i++) {
//          for (j = 0; j < N; j++) {
//              productMatrix[i][j] = 0;
//              for (k = 0; k < N; k++)
//                  productMatrix[i][j] += X[i][k] * Y[k][j];
//          }
//      }
//   }
XYMultiply:
	mov i, 0			// product matrix row counter
	mov j, 0			// product matrix column counter
	mov k, 0			// product matrix internal loop counter
	mov x13, 0	

// find X matrix value
findXMatrixOffset:			// LOOP
	mov x9, 16 			// bytes between 2D array elements
	
	mov offset, userInput		// N
	mul offset, offset, i		// N * i
	add offset, offset, k		// (N * i) + k
	mul offset, offset, x9		// ((N * i) + k) * E_size
	ldr x10, [arr_base, offset]	// load X element
// find Y matrix value
findYMatrixOffset:			// LOOP
	mov x9, 16 			// bytes between 2D array elements
	mov x12, 8			// offset for y matrix elements	

	mov offset, userInput		// N
	mul offset, offset, k		// (N * k)
	add offset, offset, j		// ((N * k) + j)
	mul offset, offset, x9		// ((N * k) + j) * E_size
	add offset, offset, x12		// +8 bytes to get to y matrix values
	ldr x11, [arr_base,offset]	// load Y element

// Matrix Multiplication
calculateProduct:					
	mul x10, x10, x11		// multiplying X and Y element
	add x13, x13, x10		// summation

	add k, k, 1			// increment column for X matrix and row for Y matrix
	cmp k, userInput		// check if calculation is complete for row/column
	b.lt findXMatrixOffset		// loop until complete
	
	mov offset, 0			// reset offset
	mov x9, 8 			// next  array elements
	mul offset, counter, x9		// finding offset for elements in product matrix

	str x13, [productarr_base, offset]	// storing product in new array
	add counter, counter,  1	// indicate that an element has been calculated

// checking for completion of Y matrix columns
YMatrixTest:				// LOOP TEST
	mov x13, 0			// reset for next product calculation
	mov k, 0			// reset column for X matrix and row for Y matrix
	add j, j, 1			// incrementing	column for Y matrix
	cmp j, userInput		// check if finished calculating column product element
	b.lt findXMatrixOffset		// loop until complete

// checking for completion of X matrix rows
XMartixTest:
	mov x13, 0			// reset for next product calculation
	mov k, 0			// reset column for X matrix and row for Y matrix
	mov j, 0			// reset row for Y matrix
	add i, i , 1			// incrementing row for X matrix
	cmp i, userInput		// check if finisshed calculating row product element
	b.lt findXMatrixOffset		// loop until complete

	mov counter, 1			// reset counter
	mov offset, 0			// reset offset

// begin printing product matrix
printProductMatrix:
	ldr x0, =printProduct		// print product matrix
	bl printf			// print message
	
ProductMatrix:
	ldr x9, [productarr_base, offset]	// load product matrix element
	add offset, offset, 8  		// update offset to next prodct matrix element
	
	ldr x0, =printNum		// print product matrix element
	mov x1, x9			// load product matrix element
	bl printf			// print message

	ldr x0, =middle			// print comma between elements
	bl printf			// print message
	
	add counter, counter, 1		// indicate how many elements have been printed

	cmp counter, sizeOfArr		// check if all elements-1  have been printed
	b.lt ProductMatrix		// loop until complete
	
	ldr x9,[productarr_base, offset]	// load last product matrix element
					
	ldr x0, =printNum		// print last element in product matrix
	mov x1, x9			// load last element
	bl printf			// print message
	
	ldr x0, =ending			// printing closing bracket
	bl printf			// print message
	
	mov counter, 0			// reset counter
	mov offset, 0			// reset offset

// calculating sum, max, and min of product matrix
sumMaxMin:
	ldr element, [productarr_base, offset]	// load first product element
	add offset, offset, 8 		// offset to next product element

	mov i , 0 			// sum initialized to zero
	mov j, element			// max initialized to first element
	mov k, element			// min initialized to first element

// calculates sum
sum:
	add counter, counter, 1		// increment counter to indicate an element has been calculated
	add i, i, element		// summationg of product matrix

// finds max value
max:	
	cmp j, element			// checking if element is greater than or equal to j (largest element)
	b.ge min			// branch if element is not largers
	mov j, element			// replace j with new largest element

// finds min value
min:	
	cmp k, element			// checking if element is smaller than or equal to k (smallest element) 
	b.le sumMaxMinTest		// branch if element is not smaller
	mov k, element			// replace k with new smallest element

// checks to see if calculation is complete
sumMaxMinTest:
	ldr element, [productarr_base, offset]	// load next element value
	add offset, offset, 8		// offset for next element
	cmp counter, sizeOfArr          // cmp to size of arr
	b.lt sum			// branch if all elements have not been calculated

	str i, [sp, struct_Sum_offset]	// storing sum in struct
	str j, [sp, struct_Max_offset]	// storing max in struct
	str k, [sp, struct_Min_offset]	// storying min in struct

	ldr x0, =printSum		// print sum of product matrix
	ldr x1, [sp, struct_Sum_offset]	// load sum value
	bl printf			// print message
	
	ldr x0, =printMax		// print max of product matrix
	ldr x1, [sp, struct_Max_offset]	// load max value
	bl  printf			// print message

	ldr x0, =printMin		// print min of product matrix
	ldr x1, [sp, struct_Min_offset]	// load min value
	bl printf			// print message	

// ends program and deallocates memory
end:				 	
	sub sp, sp, alloc		// dellocating memory for product matrix
        ldp x29, x30, [sp], 16		// retores state
        ret				// returns control to calling code


