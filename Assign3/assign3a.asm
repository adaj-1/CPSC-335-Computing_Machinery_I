// assign3a.asm
// CPSC 355 Assignment 3
// binary to decimal
// Jada Li
// UCID: 3001680

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

//		mov BCDLength, 16
//		mov BCDValue, 0xF765		// initialization of printing for loop

//		b printingBinaryAsBCD

userInput:	ldr x0, =prompt			// prompt message 
		bl printf			// print message

		ldr x0, =scan			// scan user input
		ldr x1, =n			// load  address =n to register x1
		bl scanf			// Get the first number

		ldr x14, =n			// load address =n to register x14
		ldr userInput, [x14]			// load the value of n TODO: x9 because only need to print BCD representation no need to store it??
	
		
		ldr x0, =decimalDigit
		mov x1, userInput
		bl printf
		
		mov x10, 10
		mov trueValue, 0
		mov x11, 0			// temp register for exponential counter
			
calculate:	udiv x9, userInput, x10		// calculating quotient
		msub x22, x9, x10, userInput	// calculating modulus
		
		mov userInput, x9		// updating userInput after divided by 10

	
		lsl x12, x22, x11		// LSL to find to the power two
		add trueValue, trueValue, x12	
		
		add x11, x11, 1	
		cmp userInput, xzr
		b.ne calculate
	

		ldr x0, =decimalDigit
		mov x1, trueValue
		bl printf	
	
		b exit
		
printingBinaryAsBCD:
		mov x25, BCDValue		// make copy of value
		sub x26, BCDLength, 4		// number of bits to shift
		ror x25, x25, x26		// rotate right by number of bits
		and x25, x25, 0xF		// mask by 15 in hex
		cmp x25, 0xF			// check for negative
		b.ne printBCDValue										
	
		ldr x0, =negative
		bl printf
		sub x26, x26, 4


printBCDValue:	mov x25, BCDValue
		ror x25, x25, x26
		and x25, x25, 0xF
		
		ldr x0, =decimalDigit
		mov x1, x25
		bl printf
	

		sub x26, x26, 4
		cmp x26,xzr
		b.ge printBCDValue
		
		ldr x0, =nextLine
		bl printf
		

exit:		ldp 	x29,	x30, 	[sp], 	16 	// restores state
		ret					// returns control to calling code


