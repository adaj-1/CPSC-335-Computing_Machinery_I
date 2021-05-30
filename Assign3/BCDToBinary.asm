// assign3b.asm
// CPSC 355 Assignment 3
// binary to BCD
// Jada  Li
// UCID: 30016807


.data						// must be delcared to call scanf()
n: 	.word 0					// must be delcared to call scanf()

.text
scan:		.string "%ld"						// holds user input in long integer
prompt:		.string "Please enter N (a number in BCD):\n"		// prompts user to input 
printBinary:	.string "%d"
printNeg:	.string "-"
nextLine:	.string "\n"

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)		// macro to hold user input
		define(BCDValue, x20)		// macro to hold BCD value
		define(trueValue, x21)		// macro to hold true decimal value
		define(binaryValue, x26)	// macro to hold binary value

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
	
		ldr x0, =printNeg		// prints neg symbol to indicate negative
		bl printf			//  prints neg symbol

		b decimalToBinary		// branch to decimal to binary as the negative bits do not need to be added to true value
	
findingTrueValue:
		mul x23, BCDValue, x13		// calculating correct decimal place
		add trueValue, trueValue, x23	// calculating true value
		
		mul x13, x13, x10		// incrementing to next decimal place
		mov x11, 0			// to count next set of bits	
		mov x14, 0			// initailize temp register
		mov x14, BCDValue		// to hold the BCD value
		mov BCDValue, 0			// to reset BCD value for next loop

		cmp userInput, xzr		// check if userInput is 0 now
		b.ne bcdLoop			// continue  bcdLoop conversion if not equal
	

decimalToBinary:
		mov x10, 10			// constant for calculating binary
		mov x11, 2			// initializing temp register to mod by 2
		mov x12, 1			// counts decimal place for binary
	
		mov x25, trueValue		// copying true value 

binaryLoop:	udiv x9, x25, x11		// finding the quotient
		msub x22, x9, x11, x25		// finding the modulus
				
		mov x25, x9			// moving the quotient to x25 to keep track of printed
		
		mul x22, x22, x12		// multiplier for decimal place
		add binaryValue, binaryValue, x22	// calculating binaryValue	
		
		mul x12, x12, x10		// multiplying to incrase decimal place for next print

		cmp x25, xzr			// checking if done printing
		b.ne binaryLoop			// if not finish looping
	
		ldr x0, =printBinary		// print converted binary number
		mov x1, binaryValue		// print converted binary number
		bl printf			// print converted binary number

exit:		ldr x0, =nextLine		// print next line for format
		bl printf			// print next line for format
	
		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code







