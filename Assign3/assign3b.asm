// assign3b.asm
// CPSC 355 Assignment 3
// binary to BCD 
// Jada Li
// UCID: 3001680


// how to indicate negative binary input. will you enter -1010 0110, 1111  010101, or will we have to do something else like bit extend will it also include spaces or no spaces

// for the program output do you expect printing in decimal using bcd code or in binary format like 1111 0011 with space or 11110011 no spaces
.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in BCD):\n"		// prompts user to enter BCD
decimalDigit:	.string "%d"						// used to print binary
nextLine:	.string "\n"						// used to after printing binary

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)
		define(BCDLength, x23) 		
		define(BCDValue, x24) 
		

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

convertBCD:	mov x12, 0			// initializing number of bits to shift
		mov x27, 0			// initializing positive number 
		mov BCDLength, 0		// initializing BCDLength

		cmp userInput, 0		// check if negative number
		b.gt BCDLoop			// branch to BCDLoop
		mov x27, 1			// setting as flag for negative
		neg userInput, userInput	// removing negative from trueValue to properly convert to BCD
		
BCDLoop:	add BCDLength, BCDLength, 4	// to track length of bits
		mov x9, 0			// initializing quotient
		mov x10, 10			// initializing denominator
		
		udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus

		mov userInput, x9		// copying quotient to trueValue
	
		lsl x13, x22, x12 		// LSL to shift to the proper BCD position
		add x12, x12, 4			// adding 4 to shift to next digit
		
		add BCDValue, BCDValue, x13	// storing back values in BCD Representation

		cmp userInput, xzr		// checking if finished converting all values
		b.ne BCDLoop 
	
		mov x26, BCDLength

checkNeg:	cmp x27, 1
		b.ne printingBinaryAsBCD	// not negative
		mov x28, 1111		
		
		ldr x0, =decimalDigit		
		mov x1, x28
		bl printf			
		
printingBinaryAsBCD:
		mov x25, BCDValue		// make copy of value
		sub x26, x26, 1			// number of bits to shift
		ror x25, x25, x26		// rotate right by number of bits
		and x25, x25, 0x1		// mask by everything but last digit
		cmp x26, xzr
		b.lt exit	
			
		ldr x0, =decimalDigit		
		mov x1, x25
		bl printf			

		b printingBinaryAsBCD

exit:		ldr x0, =nextLine		
		bl printf			
		
		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code


