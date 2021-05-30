// assign3a.asm
// CPSC 355 Assignment 3
// binary to BCD 
// Jada Li
// UCID: 3001680


.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in binary):\n"	// prompts user to enter binary number
decimalDigit:	.string "%d"						// used to print BCD representation
nextLine:	.string "\n"						// used to after printing BCD representation

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)		// macro to hold userInput
		define(BCDLength, x23) 		// macro to hold length of BCD value
		define(BCDValue, x24) 		// macro to hold BCD Value
		define(trueValue, x20)		// macro to hold true value
		

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
		mov trueValue, 0		// initializing trueValue
		mov x11, 0			// temp register for exponential counter

// converting userInput from binary to decimal			
calculate:	udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus
		
		mov userInput, x9		// updating userInput after divided by 10

		lsl x12, x22, x11		// LSL to find to the power two
		add trueValue, trueValue, x12	// calculating decimal value
		
		add x11, x11, 1			// increasing exponential counter
		cmp userInput, xzr		// checking if we are done converting
		b.ne calculate
						
	//	mov trueValue, -123		used  to test negative input if needed. Enter negative decimal value (-123)  here and enter positive binary number (1111011) when prompted in command line		

convertBCD:	mov x12, 0			// initializing number of bits to shift
		mov x27, 0			// initializing positive number 
		mov BCDLength, 0		// initializing BCDLength
		cmp trueValue, 0		// check if negative number
		b.gt BCDLoop			// branch to BCDLoop
		mov x27, 1			// setting as flag for negative
		neg trueValue, trueValue	// removing negative from trueValue to properly convert to BCD
		
BCDLoop:	add BCDLength, BCDLength, 4	// to track length of bits
		mov x9, 0			// initializing quotient
		mov x10, 10			// initializing denominator
		
		udiv x9, trueValue, x10		// calculating quotient
		msub x22, x9, x10, trueValue	// calculating modulus

		mov trueValue, x9		// copying quotient to trueValue
	
		lsl x13, x22, x12 		// LSL to shift to the proper BCD position
		add x12, x12, 4			// adding 4 to shift to next digit
		
		add BCDValue, BCDValue, x13	// storing back values in BCD Representation

		cmp trueValue, xzr		// checking if finished converting all values
		b.ne BCDLoop 
	
		mov x26, BCDLength		// copying BCDLength to x26

checkNeg:	cmp x27, 1			// checking for negative
		b.ne printingBinaryAsBCD	// not negative
		mov x28, 1111			// moving negative BCD representation to x28
		
		ldr x0, =decimalDigit		// printing negative
		mov x1, x28			// printing negative
		bl printf			// printing negative
		
printingBinaryAsBCD:
		mov x25, BCDValue		// make copy of value
		sub x26, x26, 1			// number of bits to shift
		ror x25, x25, x26		// rotate right by number of bits
		and x25, x25, 0x1		// mask by everything but last digit
		cmp x26, xzr			// checking if done printing
		b.lt exit			// if done printing exit
				
		ldr x0, =decimalDigit		// printing BCD
		mov x1, x25			// printing BCD
		bl printf			// pritning BCD
					
		b printingBinaryAsBCD		// continue printing

exit:		ldr x0, =nextLine		// printing next line for format
		bl printf			// printing next line for format
		
		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code


