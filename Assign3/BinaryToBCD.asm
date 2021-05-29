// assign3a.asm
// CPSC 355 Assignment 3
// binary to decimal
// Jada Li
// UCID: 3001680


// how to indicate negative binary input. will you enter -1010 0110, 1111  010101, or will we have to do something else like bit extend will it also include spaces or no spaces

// for the program output do you expect printing in decimal using bcd code or in binary format like 1111 0011 with space or 11110011 no spaces
.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in binary):\n"	// prompts user to input sequence
currentLength: 	.string "current length of binary is %d\n"		//TODO delete
rightShift:	.string "right shift is at %d\n"
decimalDigit:	.string "%d\n"
nextLine:	.string "\n"
negative:	.string "-"

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(BCDLength, x23) 
		define(BCDValue, x24) 
		define(trueValue, x20)
		define(userInput, x19)
		

main:		stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
		mov x29, sp			// updates FP to the current SP

userInput:	ldr x0, =prompt			// prompt message 
		bl printf			// print message

		ldr x0, =scan			// scan user input
		ldr x1, =n			// load  address =n to register x1
		bl scanf			// Get the first number

		ldr x14, =n			// load address =n to register x14
		ldr userInput, [x14]		// load the value of n
			
		ldr x0, =decimalDigit		// TODO delete from
		mov x1, userInput
		bl printf			//TODO delete to
		
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
						
		ldr x0, =decimalDigit		//TODO delete from
		mov x1, trueValue
		bl printf			//TODO delete to
		
		mov trueValue, -329		//TODO test please delete

convertBCD:	mov x12, 0			// initializing number of bits to shift
		mov x27, 0			// initializing positive number 
		mov BCDLength, 0		// initializing BCDLength
		cmp trueValue, 0		// check if negative number
		b.gt BCDLoop			// branch to BCDLoop

		mov x27, 1			// setting as flag for negative
		neg trueValue, trueValue	// removing negative from trueValue to properly convert to BCD
			
		
BCDLoop:	add BCDLength,BCDLength, 4	// to track length of bits
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

checkNeg:	cmp x27, 1
		b.ne printingBinaryAsBCD	// not negative
		
		mov x22, 0xF	
		lsl x13, x22, x12		// LSL to shift to the decimal position
		add BCDValue, BCDValue, x13	// accounting for 1111 additional length
		add BCDLength, BCDLength, 4	

printingBinaryAsBCD:
		mov x25, BCDValue		// make copy of value
		sub x26, BCDLength, 4		// number of bits to shift
		ror x25, x25, x26		// rotate right by number of bits
		and x25, x25, 0xF		// mask by 15 in hex
		cmp x25, 0xF			// check for negative
		b.ne printBCDValue										
	
		ldr x0, =negative		// printing negative symbol
		bl printf

		sub x26, x26, 4			// keeping track of how many bits left to print

printBCDValue:	mov x25, BCDValue		//TODO print as BCD representation
		ror x25, x25, x26		// right shifting to print 
		and x25, x25, 0xF		// masking
	
	//	and x25, x25, 0x1
	//	cmp x25, 1
	//	b.ne printZero
//printZero:

		ldr x0, =decimalDigit		//TODO delete from
		mov x1, x25
		bl printf			// TODO delete to

		sub x26, x26, 4			// keeping track of how many bits left to print
		cmp x26,xzr			// chekcing if we are done printing
		b.ge printBCDValue		
		
		ldr x0, =nextLine		// printing next line
		bl printf

exit:		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code


