// assign3a.asm
// CPSC 355 Assignment 3
// binary to BCD
// Jada  Li
// UCID: 30016807

// 1111 0001 0010 = F12 do you want the register to contain -12 or binary in integers 1111 0011 

// just to confirm the BCD will be entered with no spaces correct?

.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in binary):\n"		// prompts user to input 
printTrueValue:	.string "%d\n"
printNeg:	.string "-"

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)
		define(BCDValue, x20)
		define(trueValue, x21)		
		define(binaryValue, x26)

main:		stp x29, x30, [sp, -16]!	// saves the state of the registers used by calling code
		mov x29, sp			// updates FP to the current SP


userInput:	ldr x0, =prompt			// prompt message 
		bl printf			// print message

		ldr x0, =scan			// scan user input
		ldr x1, =n			// load  address =n to register x1
		bl scanf			// Get the first number

		ldr x14, =n			// load address =n to register x14
		ldr userInput, [x14]		// load the value of n 

calculate:	mov x10, 10			// initializing constant for finding remainder
		mov x11, 0			// intializing exponential counter
		mov x13, 1			// initializing value for conversion to decimal
		mov x23, 0			// initializing register to hold BCDValue
		mov trueValue, 0
		mov x24, 0			// initializing positive value
			
bcdLoop:	udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus
		
		mov userInput, x9		// udpating userInput after divided by 10
	
		lsl x12, x22, x11		// LSL to find to the power two
		add BCDValue,BCDValue, x12	// calculating decimal value
		
		add x11, x11, 1			// increments exponential counter
		cmp x11, 4			// if less than 4 it is the end of the BCD section
		b.lt bcdLoop
		
checkNeg:	cmp userInput, 0		// only run code if this is for most significant digits
		b.ne findingTrueValue
		mov x15, 15			// to hold negative value
		cmp x15, BCDValue
		b.ne findingTrueValue		// to account for negative value	
	
		ldr x0, =printNeg	
		bl printf

		b decimalToBinary
	
findingTrueValue:
		mul x23, BCDValue, x13		// calculating correct decimal place
		add trueValue, trueValue, x23	// calculating true value
		
		mul x13, x13, x10		// incrementing to next decimal place
		mov x11, 0			// to count next set of bits	
		mov x14, 0
		mov x14, BCDValue	
		mov BCDValue, 0		
		cmp userInput, xzr		// check if userInput is 0 now
		b.ne bcdLoop			
	

decimalToBinary:
		ldr x0, =printTrueValue
		mov x1, trueValue
		bl printf	

exit:		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code







