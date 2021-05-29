// assign3b.asm
// CPSC 355 Assignment 3
// BCD to Binary 
// Jada Li
// UCID: 3001680

.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in BCD):\n"		// prompts user to enter BCD
decimalDigit:	.string "%d"						// used to print binary
nextLine:	.string "\n"						// used to after printing binary

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)		// macro to hold user input
		define(binaryLength, x23) 	// macro to count how long binary number is
		define(binaryValue, x24) 	// macro to hold binary value
		

main:		stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
		mov x29, sp			// updates FP to the current SP

userInput:	ldr x0, =prompt			// prompt message 
		bl printf			// print message

		ldr x0, =scan			// scan user input
		ldr x1, =n			// load  address =n to register x1
		bl scanf			// Get the first number

		ldr x14, =n			// load address =n to register x14
		ldr userInput, [x14]		// load the value of n
			
		mov x10, 10			// initializing contant for finding remainder
		mov x11, 0			// temp register for exponential counter

// setting up conversion to binary
convertBCD:	mov x12, 0			// initializing number of bits to shift
		mov x27, 0			// initializing positive number 
		mov binaryLength, 0		// initializing binaryLength

		cmp userInput, 0		// check if negative number
		b.gt BCDLoop			// branch to BCDLoop
		mov x27, 1			// setting as flag for negative
		neg userInput, userInput	// removing negative from trueValue to properly convert to BCD

// looping to converting userInput to binary
BCDLoop:	add binaryLength, binaryLength, 4	// to track length of bits
		mov x9, 0			// initializing quotient
		mov x10, 10			// initializing denominator
		
		udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus

		mov userInput, x9		// copying quotient to trueValue
	
		lsl x13, x22, x12 		// LSL to shift to the proper binary position
		add x12, x12, 4			// adding 4 to shift to next digit
		
		add binaryValue, binaryValue, x13	// storing back values in binary

		cmp userInput, xzr		// checking if finished converting all values
		b.ne BCDLoop 
	
		mov x26, binaryLength		// copying binaryLength to be used for printing

// checks for negative input and prints accordingly
checkNeg:	cmp x27, 1			// checking if user input was negative
		b.ne printingBCDAsBinary	// not negative
		mov x28, 1111			// adding leading 1's to indicate negative
		
		ldr x0, =decimalDigit		// printing leading 1's
		mov x1, x28			// printing leading 1's
		bl printf			// printing leading 1's

// prints BCD value as Binary
printingBCDAsBinary:
		mov x25, binaryValue		// make copy of value
		sub x26, x26, 1			// number of bits to shift
		ror x25, x25, x26		// rotate right by number of bits
		and x25, x25, 0x1		// mask by everything but last digit
		cmp x26, xzr			// check if we have finished printing binary
		b.lt exit			// exit when done
			
		ldr x0, =decimalDigit		// printing each binary digit
		mov x1, x25			// printing each binary digit
		bl printf			// printing each binary digit
		
		b printingBCDAsBinary		// looping until printing is complete

exit:		ldr x0, =nextLine		// printing next line for formating
		bl printf			// printing next line for formatting
		
		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code



