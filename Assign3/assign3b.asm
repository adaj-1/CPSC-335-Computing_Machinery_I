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
printTrueValue:	.string "the True Value is %d\n"
printOne:	.string "1"
printZero:	.string "0"
printSpace:	.string " "

		.balign 4			// ensures instructions are properly aligned
		.global main			// makes the label "main" visible to the linker

		define(userInput, x19)
		define(BCDValue, x20)
		define(trueValue, x21)		

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

bcdLoop:	udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus
		
		mov userInput, x9		// udpating userInput after divided by 10
	
		lsl x12, x22, x11		// LSL to find to the power two
		add BCDValue,BCDValue, x12	// calculating decimal value
		
		add x11, x11, 1			// increments exponential counter
		cmp x11, 4			// if less than 4 it is the end of the BCD section
		b.lt bcdLoop
	
	
		mul x23, BCDValue, x13		// calculating correct decimal place
		add trueValue, trueValue, x23	// calculating true value
		mul x13, x13, x10		// incrementing to next decimal place
		mov x11, 0			// to count next set of bits	
		mov x14, 0
		mov x14, BCDValue	
		mov BCDValue, 0		
		cmp userInput, xzr		// check if userInput is 0 now
		b.ne bcdLoop			
		
		mov x15, 15			// to hold negative value
		cmp x14, x15
		b.ne decimalToBinary
		mul x14, x14, x13		// to calculate decimal position
		udiv x14, x14, x10 		// to account for the additional increment		
		sub trueValue, trueValue, x14	
		mov x24, 1			// to a ccount for negative value	

	
		ldr x0, =printTrueValue
		mov x1, trueValue
		bl printf
		
decimalToBinary:
		mov x11, 1			// initializing temp register to count 4 bits
		mov x12, 0
		mov x13, 4
	
binaryLoop:	cmp trueValue, 0
		b.eq pZero
		
		cmp trueValue, 1
		b.eq pOne
		
		add x11, x11, 1			// counting bits to account for spaces
		udiv x12, x11, x13		// checking if four bits have been printed
		msub x12, x11, x13, x12		// if four bits have been printed msub will be 0
		cmp x12, 0
		b.eq pSpace
		
		mov x10, 2
		udiv x9, trueValue, x10
		msub x22, x9, x10, trueValue
	
		mov trueValue, x9
		
		cmp x22, 1
		b.ne pZero 

pOne:	ldr x0, =printOne
		bl printf
		
		cmp trueValue, 1
		b.ne binaryLoop
		b exit
	
pZero:	ldr x0, =printZero
		bl printf
		
		cmp trueValue, 0
		b.ne binaryLoop
		b exit

pSpace:	ldr x0, =printSpace
		bl printf
		mov x11, 1
		b binaryLoop	

exit:		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code







