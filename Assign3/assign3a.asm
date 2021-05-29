// assign3a.asm
// CPSC 355 Assignment 3
// binary to BCD
// Jada  Li
// UCID: 30016807

.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in binary):\n"	// prompts user to input binary 
printBCDValue:	.string "%d\n"						// used to print true value
printNeg:	.string "-"						// user to print negative

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)		// macro to hold user input
		define(binaryValue, x20)	// macro to hold binaryValue
		define(BCDValue, x21)		// macro to hold BCD value

main:		stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
		mov x29, sp			// updates FP to the current SP


userInput:	ldr x0, =prompt			// prompt message 
		bl printf			// print message

		ldr x0, =scan			// scan user input
		ldr x1, =n			// load  address =n to register x1
		bl scanf			// Get the first number

		ldr x14, =n			// load address =n to register x14
		ldr userInput, [x14]		// load the value of n 

// setting up to convert binary to BCD value
calculate:	mov x10, 10			// initializing constant for finding remainder
		mov x11, 0			// intializing exponential counter
		mov x13, 1			// initializing value for conversion to decimal
		mov x23, 0			// initializing register to hold binaryValue
		mov BCDValue, 0			// initializing BCDValue
		mov x24, 0			// initializing positive value

// loop to calculate BCD value			
bcdLoop:	udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus
		
		mov userInput, x9		// updating userInput after divided by 10
	
		lsl x12, x22, x11		// LSL to find to the power two
		add binaryValue,binaryValue, x12	// calculating decimal value
		
		add x11, x11, 1			// increments exponential counter
		cmp x11, 4			// if less than 4 it is the end of the BCD section
		b.lt bcdLoop			// loops back to bcd if its not done calculating binary
		
checkNeg:	cmp userInput, 0		// only run code if this is for most significant digits
		b.ne findingBCDValue		// skipping over if user inptu was not negative
		mov x15, 15			// to hold negative value
		cmp x15, binaryValue		// cheking to see if input value was negative
		b.ne findingBCDValue		// to account for negative value	
	
		ldr x0, =printNeg		// printing negative symbol
		bl printf			// printing negative symbol

		b binaryToBCD		// branching to print
	
findingBCDValue:
		mul x23, binaryValue, x13	// calculating correct decimal place
		add BCDValue, BCDValue, x23	// calculating true value
		
		mul x13, x13, x10		// incrementing to next decimal place
		mov x11, 0			// to count next set of bits	
		mov x14, 0			// initialized to hold binaryValue	
		mov x14, binaryValue		// passing in binaryValue
		mov binaryValue, 0		// zeroing binaryValue to calculate next binary bits
		cmp userInput, xzr		// check if userInput is 0 now
		b.ne bcdLoop			
	

binaryToBCD:
		ldr x0, =printBCDValue		// printing BCD Value
		mov x1, BCDValue		// printing BCD Value
		bl printf			// printing BCD Value

exit:		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code







