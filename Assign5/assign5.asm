// CPSC 355 Assign4
// Jada Li
// UCID: 30016807

.data
//TODO fix message for -1 and 0 input

.text
msg_InputErr1:		.string "Input Error: You need to enter Player Name and N value\n"
msg_InputErr2:		.string "Input Error: N value must be greater than 0.\n" 
msg_StartOrQuit:	.string "Hit return to begin...\nEnter q or Q anytime to exit...\n"
msg_CharInput:		.string "%c"
msg_Quitting:		.string "Quitting\n"
msg_ClearScreen:	.string "clear"
msg_EnterCoord1: 	.string	"Enter the coordinates of the first card:\n"
msg_EnterCoord2:        .string "Enter the coordinates of the second card:\n"
msg_MatchedResult:	.string "Match!\nScore: %d\nPress any key to continue...\n"
msg_NotMatchResult:	.string "You are %d card away!\nScore: %d\nPress any key to continue...\n"

msg_CoordError:		.string	"Input Error: Select a coordinate between %d and %d.\n"
msg_CardAlreadyMatched: .string	"Input Error: This card has already been matched.\n"
msg_CoordDuplicated:	.string "Input Error: Select a new coordinate for your second guess.\n"

msg_QuitScore:		.string "You Quit\nScore: %d\n"
msg_GameOverScore:	.string "Game Over\nYou Lose\nScore: %d\n"
msg_WonScore:		.string "You Win!\nScore: %d\n"

string_Filename:                .string "assign5.log"
string_Append:                  .string "a+"
string_Result:                  .string "%s %d\n"

string_BoardX:                  .string "  X"
string_BoardValue:              .string "%3d"
string_BoardCr:                 .string "\n"
string_Space:                   .string " "

define(userInput,x19)	//TODO delete
define(arr_base, x20)	//TODO delete

define(i_r, w9)		//TODO delete

define(MAX_N_SIZE, 10)	//TODO remove
define(MIN_N_SIZE, 1)	//TODO remove

.balign 4				// ensures instructions are properly aligned
.global main				// makes the label "main" visible to the linker


// randomNum
//int randomNum (int minimum, int maximum)
//      w0 = minimum
//      w1 = maximum
randomNum:
        minimum_size = 4				//
        maximum_size = 4
        total_size = minimum_size + maximum_size
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        minimum_save = 16			// sp offset
        maximum_save = 20			// offset from minimum
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     w0, [sp, minimum_save]
        str     w1, [sp, maximum_save]

        // srand(time(0))       // seed a random number generator
        mov     x0, 0
        bl      time
        //TODO uncomment bl      srand
        bl      rand            // w0 contains returned random value

        // return rand() % (maximum + 1 - minimum) + minimum;
        // w0 = rand()
        ldr     w1, [sp, maximum_save]
        mov     w2, 1
        add     w1, w1, w2                      // w1 = maximum + 1
        ldr     w3, [sp, minimum_save]
        sub     w1, w1, w3                      // w1 = w1 - minimum
        sdiv    w2, w0, w1                      // w2 = (rand / w1) * w1
        mul     w2, w2, w1			//TODO modding and multiplying like in BCD assignment
        sub     w0, w0, w2                      // rand - w2 to obtain the remainder
        add     w0, w0, w3                      // + minimum to put number in max/min range

        ldp     x29, x30, [sp], dealloc
        ret


// void swap( 	int *cards, 
//		int i, 
//		int j )
swap:
        cardsPtr_size = 8			// cards pointer address
        i_size = 4
        j_size = 4
        total_size = 16
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        cardsPtr_save = 16
        i_save = 24
        j_save = 28
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     x0, [sp, cardsPtr_save]
        str     w1, [sp, i_save]
        str     w2, [sp, j_save]

        ldrsw   x1, [sp, i_save]        // ensure upper 8 byte zeroed 
        ldrsw   x2, [sp, j_save]        // ensure upper 8 byte zeroed

        mov     x3, 4           // 4 byte for each integer
        mul     x1, x1, x3      // address offset for i element
        mul     x2, x2, x3      // address offset for j element

        ldr     x0, [sp, cardsPtr_save]
        add     x3, x0, x1      // calc address location for cards[i]
        ldr     w4, [x3]        // x4 = cards[i]

        ldr     x0, [sp, cardsPtr_save]
        add     x5, x0, x2      // calc address location for cards[j]
        ldr     w6, [x5]        // x6 = cards[j]

        str     w6, [x3]        // swap card[i] and card[j] values
        str     w4, [x5]

        ldp     x29, x30, [sp], dealloc
        ret

//
// void shuffle( int *cards, 
//		 int n)
shuffle:
        cardsPtr_size = 8
        n_size = 4
        x19_size = 8				// allocate space to store register
        x20_size = 8				// TODO used for looping (i)
        x21_size = 8
        total_size = 36
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        cardsPtr_save = 16
        n_save = 24
        x19_save = 28
        x20_save = 36
        x21_save = 44
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     x0, [sp, cardsPtr_save]
        str     w1, [sp, n_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        //for(int i = 0; i < 2*n*n; i++)
        //      int j = randomNum( i, 2*N*N - 1);
        //      swap(cards, i, j);
        mov     w19, w1			// w19 = n
        mul     w19, w19, w1		// w19 = n*n
        lsl     w19, w19, 1             // w19 = 2*n*n
        mov     w20, 0                  // w20 = i
shuffle_repeat:
        mov     w0, w20                 // passing in i
        sub     w1, w19, 1              // passing in 2*n*n - 1
        bl      randomNum
        mov     w21, w0                 // w21 = j = random number

        ldr     x0, [sp, cardsPtr_save] // cards pointer
        mov     w1, w20
        mov     w2, w21
        bl      swap

        add     w20, w20, 1             // i++
        cmp     w20, w19
        blt     shuffle_repeat

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
        ret


//void initialize(      int n,
//                      int numRowColumn,
//                      int numCards,
//                      int board[numRowColumn][numRowColumn],
//                      int displayBoard[numRowColumn][numRowColumn])
initialize:
        n_size = 4
        numRowColumn_size = 4
        numCards_size = 4
        boardPtr_size = 8
        displayBoardPtr_size = 8
        cards_size = 128
        x19_size = 8
        x20_size = 8
        x21_size = 8
	x22_size = 8
        total_size = 188
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        n_save = 16
        numRowColumn_save = 20
        numCards_save = 24
        boardPtr_ssave = 28
        displayBoardPtr_save = 36
        cards_save = 44
        x19_save = 172
        x20_save = 180
        x21_save = 188
	x22_save = 196
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     w0, [sp, n_save]
        str     w1, [sp, numRowColumn_save]
        str     w2, [sp, numCards_save]
        str     x3, [sp, boardPtr_save]
        str     x4, [sp, displayBoardPtr_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
	str	x22, [sp, x22_save]

	// for (int i = 0; i < numCards ; i++)
	//     cards[i] = i
        mov     w0, 0                       // i = 0
        ldr     w2, [sp, numCards_save]     // w2 = numCards
        mov     x1, sp
        add     x1, x1, cards_save		// get to local variable
initialize_1:
        str     w0, [x1]
        add     x1, x1, 4               // 4 byte integer
        add     w0, w0, 1               // i++
        cmp     w0, w2
        blt     initialize_1

        mov     x0, sp
        add     x0, x0, cards_save
        ldr     w1, [sp, n_save]
        bl      shuffle

	// int a = 0;
	// for ( int i = 0; i < numRowColumn; i++ )
	//     if (i == n)
	//         shuffle(cards, n)
	//         a = 0;
	//     for ( int j = 0; j < numRowColumn; j++ )
	//        ***TODO - not implemented***  if ( a < sizeof(cards) )
	//             board[i][j]= cards[a];
	//	       a++;
	ldr	x22, [sp, boardPtr_save]	// boardPtr = w22
	mov	w19, 0				// a = w19 = 0
	mov	w20, 0				// i = w20 = 0
initialize_i_loop1:
	mov	w21, 0				// j = w21 = 0
	ldr	w1, [sp, n_save]
	cmp	w20, w1				// if (i == n)
	bne	initialize_j_loop1
	mov     x0, sp
        add     x0, x0, cards_save
	ldr     w1, [sp, n_save]		// para 2 n 
 	bl	shuffle
	mov	w19, 0				// a = 0
initialize_j_loop1:
	mov	x0, 0
	mov	w0, w19				// calculate address of cards[a]
	mov	x1, 4
	mul	x0, x0, x1			// a*4
	mov     x1, sp
        add     x1, x1, cards_save
	add	x0, x0, x1			// card pointer + a*4
	ldr	w1, [x0]
	str	w1, [x22]			// boardPtr[i][j] = cards[a]
	add	w19, w19, 1			// a++

	add	w22, w22, 4			// boardPtr++
	add	w21, w21, 1			// j++
	ldr	w0, [sp, numRowColumn_save]
	cmp	w21, w0
	blt	initialize_j_loop1

	add     w20, w20, 1                     // i++
	ldr     w0, [sp, numRowColumn_save]
	cmp	w20, w0
	blt	initialize_i_loop1

	// for ( int i = 0; i < numRowColumn; i++ )
	//    for ( int j = 0; j < numRowColumn; j++ )
	//       displayBoard[i][j]= -1;	
        ldr     x22, [sp, displayBoardPtr_save]        // displayBoardPtr = w22
        mov     w20, 0                          // i = w20 = 0
initialize_i_loop2:
        mov     w21, 0                          // j = w21 = 0
initialize_j_loop2:
        mov	w0, -1
	str     w0, [x22]                       // displayBoardPtr[i][j] = -1
        add     w22, w22, 4                     // boardPtr++
        add     w21, w21, 1                     // j++
        ldr     w0, [sp, numRowColumn_save]
        cmp     w21, w0
        blt     initialize_j_loop2

        add     w20, w20, 1                     // i++
        ldr     w0, [sp, numRowColumn_save]
        cmp     w20, w0
        blt     initialize_i_loop2

initialize_end:
        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
	ldr	x22, [sp, x22_save]
        ldp     x29, x30, [sp], dealloc
        ret

//
//void display( int numRowColumn, 
//		int dboard[numRowColumn][numRowColumn] )
display:
        numRowColumn_size = 4
        dboardPtr_size = 8
        x19_size = 8
        x20_size = 8
        x21_size = 8
        total_size = 36
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        numRowColumn_save = 16
        dboardPtr_save = 20
        x19_save = 28
        x20_save = 36
        x21_save = 44
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     w0, [sp, numRowColumn_save]
        str     x1, [sp, dboardPtr_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        // for (int i = 0; i < numRowColumn ; i++
        //      for (int j = 0; j < numRowColumn ; j++)
        //              if (dboard[i][j] == -1)
        //                      printf("%3c", 'X')
        //              else
        //                      printf("%3d", dboard[i][j]);
        //      printf("\n");
        // printf("\n");

        mov     x19, x1                 // x19 to store dboardPtr
        mov     x20, 0                  // i = 0
display_i_loop:
        mov     x21, 0                  // j = 0
display_j_loop:
        ldr     w1, [x19]               // x19 = *dboardPtr
        cmp     w1, -1
        bne     display_1
        ldr     x0, =string_BoardX
        bl      printf
        b       display_2
display_1:
        ldr     x0, =string_BoardValue
        ldr     w1, [x19]               // x19 contains dboardPtr address
        bl      printf
display_2:
        add     x19, x19, 4             // dboardPtr + 4; point to next value
        add     w21, w21, 1             // j++
        ldr     w0, [sp, numRowColumn_save]
        cmp     w21, w0
        blt     display_j_loop

        ldr     x0, =string_BoardCr
        bl      printf

        add     w20, w20, 1
        ldr     w0, [sp, numRowColumn_save]
        cmp     w20, w0
        blt     display_i_loop

        ldr     x0, =string_BoardCr
        bl      printf

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
        ret

//void updateBoard(     int row,
//                      int col,
//                      int numRowColumn,
//                      int board[numRowColumn][numRowColumn],
//                      int displayBoard[numRowColumn][numRowColumn])
updateBoard:
        row_size = 4
        col_size = 4
        numRowColumn_size = 4
        boardPtr_size = 8
        displayBoardPtr_size = 8
        x19_size = 8
        x20_size = 8
        x21_size = 8
        total_size = 52
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        row_save = 16
        col_save = 20
        numRowColumn_save = 24
        boardPtr_save = 28
        displayBoardPtr_save = 36
        x19_save = 44
        x20_save = 52
        x21_save = 60
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     w0, [sp, row_save]
        str     w1, [sp, col_save]
        str     w2, [sp, numRowColumn_save]
        str     x3, [sp, boardPtr_save]
        str     x4, [sp, displayBoardPtr_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]


        //displayBoard[row][col] = board[row][col];
        mov     x5, 0           // clear the entire register
        mul     w5, w2, w0      // numRowColumn * row
        add     w5, w5, w1      // add col
        mov     w6, 4
        mul     w5, w5, w6      // *4 byte integer
        add     x3, x3, x5      // add offset to boardPtr
        add     x4, x4, x5      // add offset to displayBoardPtr
        ldr     w6, [x3]        // get board[row][col] value
        str     w6, [x4]        // update displayBoard[row][col] value


        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
        ret

//int findDistance(     int numRowColumn,
//                      int board[numRowColumn][numRowColumn],
//                      int row1,
//                      int col1,
//                      int row2,
//                      int col2)
findDistance:

        numRowColumn_size = 4
        boardPtr_size = 8
        row1_size = 4
        col1_size = 4
        row2_size = 4
        col2_size = 4
        x19_size = 8
        x20_size = 8
        x21_size = 8
        x22_size = 8
        total_size = 60
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        numRowColumn_save = 16
        boardPtr_save = 20
        row1_save = 28
        col1_save = 32
        row2_save = 36
        col2_save = 40
        x19_save = 44
        x20_save = 52
        x21_save = 60
        x22_save = 68
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     w0, [sp, numRowColumn_save]
        str     x1, [sp, boardPtr_save]
        str     w2, [sp, row1_save]
        str     w3, [sp, col1_save]
        str     w4, [sp, row2_save]
        str     w5, [sp, col2_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]

        //int targetValue = board[row1][col1];
	mov	x0, 0				// clear high bytes
	ldr	w0, [sp, row1_save]		// row1 * numRowColumn
	ldr	w1, [sp, numRowColumn_save]
	mul	w0, w0, w1
	ldr	w1, [sp, col1_save]		// row1 * numRowColumn + col1
	add	w0, w0, w1
	mov	w1, 4				// *4 to get offset address
	mul	w0, w0, w1
	ldr	x1, [sp, boardPtr_save]
	add	x0, x0, x1			// address of board[row1][col1]
        ldr     w19, [x0]                       // save targetValue to w19

        //for (int i=0; i<numRowColumn; i++)
        //      for (int j = 0; j < numRowColumn ; j++)
        //              if (i != row1 && j != col1)
        //                      if (board[i][j] == targetValue)
        //                              return (abs(i-row2) + abs(j - col2));

        ldr     x22, [sp, boardPtr_save]        // board[0][0] address
        mov     x20, 0                          // i = 0
findDistance_i_loop:
        mov     x21, 0                          // j = 0
findDistance_j_loop:
	ldr	w0, [sp, row1_save]
        cmp     w20, w0                         // if i != row1
        bne     findDistance_cmp                 //     jump to compare
	ldr     w0, [sp, col1_save]
        cmp     w21, w0                         // if j == col1
        beq     findDistance_not_match          //      same row/col, don't compare
findDistance_cmp:
        ldr     w0, [x22]			// get  board[i][j] value
        cmp     w19, w0                         // if targetValue == board[i][j]
        bne     findDistance_not_match

        // Matched - calc distance!!
	ldr	w0, [sp, row2_save]
        sub     w1, w20, w0                    // i - row2
        cmp     w1, 0
        bgt     findDistance_1
        neg     w1, w1                        // if < 0, invert
findDistance_1:
	ldr	w0, [sp, col2_save]
        sub     w2, w21, w0			// j - col2
	cmp	w2, 0
        bgt     findDistance_2
        neg     w2, w2
findDistance_2:
        add     w0, w1, w2                    // sum row & col distance
        b       findDistance_end

findDistance_not_match:
        add     x22, x22, 4                     // board + 4; move to next value
        add     w21, w21, 1                     // j++
	ldr	w0, [sp, numRowColumn_save]
        cmp     w21, w0                         // if j<numRowColumn
        blt     findDistance_j_loop

        add     w20, w20, 1                     // i++
	ldr     w0, [sp, numRowColumn_save]
        cmp     w20, w0                         // if j < numRowColumn
        blt     findDistance_i_loop

        // finished i & j loops
        mov     w0, -1

findDistance_end:
        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
        ldp     x29, x30, [sp], dealloc
        ret


// void logFile( char *playerName, 
//		 int score )
logFile:
        playerName_size = 8
        score_size = 4
        total_size = playerName_size + score_size
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        playerName_save = 16
        score_save = 24
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        // FILE *fp;
        // fp = fopen("assign5.log", "a+");

        str     x0, [sp, playerName_save]
        str     w1, [sp, score_save]

        ldr     x0, = string_Filename
	ldr	x1, = string_Append
	bl	fopen
	// x0 contains file handle

        // fprintf(fp,"%s %d\n", playerName, score);
              	
	ldr	x1, = string_Result
	ldr	x2, [sp, playerName_save]
	ldr	x3, [sp, score_save]
	bl	fprintf

        ldp     x29, x30, [sp], dealloc
        ret


// bool stringToInt( char *inputString, 
//		     int *value )
stringToInt:
        inputString_size = 8
        valuePtr_size = 8
        x19_size = 8
        x20_size = 8
        x21_size = 8
        total_size = 40
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        inputString_save = 16
        valuePtr_save = 24
        x19_save = 32
        x20_save = 40
        x21_save = 48
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     x0, [sp, inputString_save]
        str     x1, [sp, valuePtr_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        // *value = atoi(inputString);
        bl      atoi                            // x0 already point to inputString
        ldr     x1, [sp, valuePtr_save]         // load pointer to x1
        str     w0, [x1]                        // store return value to *value

        // if (*value == 0 && inputString[0] != '0')
        //      return false;
        // else
        //      return true;
        cmp     w0, 0
        bne     stringToInt_true
        ldr     x0, [sp, inputString_save]
        ldrb    w0, [x0]                        // get the first char
        cmp     w0, '0'
        beq     stringToInt_true
        mov     w0, 0
        b       stringToInt_finish
stringToInt_true:
        mov     w0, 1
stringToInt_finish:
        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
        ret


// bool getRowColumn( bool *quitting, 
//		      int *row, 
//		      int *col )
getRowColumn:
        quittingPtr_size = 8
        rowPtr_size = 8
        colPtr_size = 8
        inputString_size = 64                   // char [64]
        string1Ptr_size = 8
        string2Ptr_size = 8
        x19_size = 8
        x20_size = 8
        x21_size = 8
        total_size = 128+128
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        quittingPtr_save = 16
        rowPtr_save = 24
        colPtr_save = 32
        inputString_save = 40
        string1Ptr_save = 104
        string2Ptr_save = 112
        x19_save = 120
        x20_save = 128
        x21_save = 136
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        //save input parameters
        str     x0, [sp, quittingPtr_save]
        str     x1, [sp, rowPtr_save]
        str     x2, [sp, colPtr_save]
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        // fgets(inputString, 64, stdin);
        adrp    x0, stdin                       // TODO add comment?? 
        add     x0, x0, :lo12:stdin		// TODO not sure what this is??
        ldr     x2, [x0]
        mov	x0, sp
	add	x0, x0, inputString_save
	mov     w1, 64
        bl      fgets

        //string1 = strtok(inputString, " ");
	mov	x0, sp
	add	x0, x0, inputString_save
        ldr     x1, =string_Space
        bl      strtok
        str     x0, [sp, string1Ptr_save]

        // if (string1 != NULL)
        //      if (string1[0] == 'q' || string1[0] == 'Q')
        //              *quitting= true;
        //              return true;
        //      else if (stringToInt(string1, row))
        //              string2 = strtok (NULL, " ");
        //              if (string2 != NULL)
        //                      if (stringToInt(string2, col))
        //                              return true;

        // if (string1 != NULL)
        cmp     x0, 0
        beq       getRowColumn_end

        // if (string1[0] == 'q' || string1[0] == 'Q')
        ldrb    w1, [x0]                // x0 = string1
        cmp     w1, 'q'
        beq     getRowColunm_quit
        cmp     w1, 'Q'
        beq     getRowColunm_quit

        // else if (stringToInt(string1, row))
        ldr	x0, [sp, string1Ptr_save]
	ldr	x1, [sp, rowPtr_save]
        bl      stringToInt
        and     w0, w0, 0xFF            // bool return, mask off the high bytes
        cmp     w0, 0
        beq     getRowColunm_quit

        // string2 = strtok (NULL, " ");
        // if (string2 != NULL)
        //     if (stringToInt(string2, col))
        //        return true;
	mov     x0, 0
        ldr     x1, =string_Space
        bl      strtok
        str     x0, [sp, string2Ptr_save]
        cmp     x0, 0
        beq     getRowColumn_end
	ldr     x0, [sp, string2Ptr_save]
        ldr     x1, [sp, colPtr_save]
        bl      stringToInt
        and     w0, w0, 0xFF
        b       getRowColumn_end

getRowColunm_quit:
        // *quitting= true;
        // return true;
	ldr	x0, [sp, quittingPtr_save]
        mov	w1, 1
        strb    w1, [x0]                                
        mov     w0, 1				// return true i.e. quit
        b       getRowColumn_end


getRowColumn_end:

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
        ret

////////////////////////////////////////////////////////////////////////
main:  
        playerName_size = 24            // char playerName[24]
	tmpValue_size = 4		// int tmpValue
	numRowColumn_size = 4		// int numRowColumn
	score_size = 4			// int score
	maxRowColumn_size = 4		// int maxRowColumn
	numCards_size = 4		// int numCards
	boardPtr_size = 8 		// int* boardPtr
	displayBoardiPtr_size = 8	// int* displayBoard
	userQuitGame_size = 4		// bool userQuitGame
	ch1_size = 4			// char ch1
	numCardsMatch_size = 4		// int numCardsMatched
	invalidCoord1_size = 4		// bool invalidCoord1
	invalidCoord2_size = 4		// bool invalidCoord2
	distance_size = 4		// int distance
	nValue_size = 4			// int nValue

	total_size = 88		//TODO changed from 84

        alloc = -(16 + total_size) & -16          // 0 size for testing only
        dealloc = -alloc

	playerName_save = 16
	tmpValue_save = 40
        numRowColumn_save = 44
        score_save = 48
        maxRowColumn_save = 52
        numCards_save = 56
        boardPtr_save = 60
        displayBoardPtr_save = 68
	userQuitGame_save = 76
	ch1_save = 80 
	numCardsMatched_save = 84
	invalidCoord1_save = 88
	invalidCoord2_save = 92
	distance_save = 96
	nValue_save = 100

	stp 	x29, x30, [sp, alloc]!	// saves the state of the registers used by calling code
        mov 	x29, sp			// updates FP to the current SP

	cmp 	w0, 3			// w0 argc - check if argv == 3
	bne	err1
       
	mov     x19, x1                 // save input arguments to x19

	// get player name
        ldr     x1, [x19, 8]            // 8 byte offset to account for the program name
        mov     x0, sp
        add     x0, x0, playerName_save
        bl      strcpy

        // get N value
	ldr     x0, [x19, 16]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str     w0, [sp, nValue_save]

	// check N value within the max and min sizes
	ldr	w0, [sp, nValue_save] 
	cmp	w0, 1
	blt	err2

	// numRowColumn = 2*n
	mov	w1, 2	
	mul	w0, w0, w1
	str	w0, [sp, numRowColumn_save]

	// set starting score = 2*n
	ldr     w0, [sp, numRowColumn_save]
	str     w0, [sp, score_save]

	// set maxRowColumn = numRowColumn - 1
	mov	w1, 1
	sub	w0, w0, w1
	str	w0, [sp, maxRowColumn_save]

	// set numCards = 2*n*n
	ldr     w0, [sp, nValue_save]
 	mul	w0, w0, w0
	mov	w1, 2
	mul	w0, w0, w1
	str	w0, [sp, numCards_save]

	// Allocate memory for boardPtr_m
	mov	w0, 4				// 4 byte integers
	ldr     w1, [sp, numRowColumn_save]
	mul	w0, w0, w1
	mul	w0, w0, w1
	mov	x20, x0				// save for displayBoard
	bl      malloc
	str     x0, [sp, boardPtr_save]

        // Allocate memory for displayBoardPtr_m
        mov     x0, x20
        bl      malloc
        str     x0, [sp, displayBoardPtr_save]

	// initialize(N, numRowColumn, numCards, board, displayBoard);	
	ldr     w0, [sp, nValue_save]	
	ldr     w1, [sp, numRowColumn_save]
	ldr	w2, [sp, numCards_save]
	ldr	x3, [sp, boardPtr_save]
	ldr     x4, [sp, displayBoardPtr_save]
	bl	initialize	
	
	// display(numRowColumn, board)
	ldr     w0, [sp, numRowColumn_save]
	ldr     x1, [sp, boardPtr_save]
	 bl	display

	// bool userQuitGame = false;
	mov	w0, 0
	str	w0, [sp, userQuitGame_save]

	// printf( "Hit return to begin...\nEnter q or Q anytime to exit...\n" )
	ldr     x0, = msg_StartOrQuit
	bl	printf

	// scanf("%c", &ch1);
        ldr     x0, = msg_CharInput
        mov     x1, sp
        add     x1, x1, ch1_save
        bl      scanf

	// if(ch1 == 'q' || ch1 == 'Q')
	//    userQuitGame= true;
	//    printf("quitting\n");
	// else
	//    system("clear");
	//    display(numRowColumn, displayBoard);

	mov     x0, sp
        add     x0, x0, ch1_save
	ldrb	w1, [x0]
	cmp	w1, 'q'
	beq 	main_quit
	cmp     w1, 'Q'
	beq 	main_quit

	ldr     x0, = msg_ClearScreen
	bl	system
	
        ldr     w0, [sp, numRowColumn_save]
        ldr     x1, [sp, displayBoardPtr_save]
	bl	display

	
        // Initialize score = 2*n;
        ldr     w0, [sp, nValue_save]
        mov     w1, 2
        mul     w0, w0, w1
        str     w0, [sp, score_save]

	// Initialize numCardsMatched
	mov	w0, 0
	str	w0, [sp, numCardsMatched_save]

	b	main_continue
main_quit:	
        mov     w0, 1
	str	w0, [sp, userQuitGame_save]
	ldr     x0, = msg_Quitting
        bl      printf
	b 	main_user_quit_game

main_continue:
	// user quit game
	ldr     w0, [sp, userQuitGame_save]
	cmp	w0, 0
	bgt	main_user_quit_game

	// score <= 0
        ldr	w0, [sp, score_save]
	cmp	w0, 0
	ble	main_game_over	

	// numCardsMatched >= numCards i.e. winning
        ldr	w0, [sp, numCardsMatched_save]
        ldr	w1, [sp, numCards_save]
	cmp	w0, w1
	bge	main_won


	// bool invalidCoord1 = true;
	// bool invalidCoord2 = true;
	mov	w0, 1
	str	w0, [sp, invalidCoord1_save]
	str	w0, [sp, invalidCoord2_save]

main_invalidCoord1:

	// printf("Enter the coordinates of the first card:\n");
	ldr	x0, = msg_EnterCoord1 
	bl	printf

	mov	x0, sp
	add	x0, x0, userQuitGame_save
        mov     x1, sp
        add     x1, x1, row1_save
        mov     x2, sp
        add     x2, x2, col1_save
	bl	getRowColumn
	cmp	x0, 0
	bne	main_check_user_quit1
main_coord1_error:
	// printf("Input Error: Select a coordinate between %d and %d.\n", 0, maxRowColumn); 
	mov	x1, 0
	ldr 	x2, [sp, maxRowColumn_save]
	ldr     x0, = msg_CoordError
        bl      printf
	b 	main_invalidCoord1		// get input again

main_check_user_quit1:
	ldr	w0, [sp, userQuitGame_save]	
	cmp	w0, 0
	bne	main_user_quit_game

	// if (row1 < 0 || col1 < 0 || row1 > maxRowColumn || col1 > maxRowColumn)
	ldr 	w0, [sp, row1_save]
	cmp	w0, 0
	blt	main_coord1_error

	ldr	w1, [sp, maxRowColumn_save]
	cmp	w0, w1
	bgt	main_coord1_error

        ldr     w0, [sp, col1_save]
        cmp     w0, 0
        blt     main_coord1_error

        ldr     w1, [sp, maxRowColumn_save]
        cmp     w0, w1
        bgt     main_coord1_error

	// if (displayBoard[row1][col1] != -1)
	ldr     x0, [sp, displayBoardPtr_save]
	mov	x1, 0				// clear upper bytes to zero could use ldrsw as well
	mov	x2, 0
	mov	x3, 0
	ldr	w1, [sp, row1_save]
	ldr	w2, [sp, numRowColumn_save]
	mul	w1, w1, w2	
	ldr	w3, [sp, col1_save]
	add	w1, w1, w3
	mov 	w2, 4				// 4 bytes
	mul	w1, w1, w2
	add	x0, x0, x1			// add to the displayBoardPtr + offset
	ldr	w1, [x0]
	cmp	w1, -1
	beq	main_valid_coor1
	
	ldr	x0, = msg_CardAlreadyMatched
        bl      printf
	beq     main_invalidCoord1

main_valid_coor1:
	mov     w0, 0				// set coord1 as valid
        str     w0, [sp, invalidCoord1_save]

	// if (userQuitGame)
	//    break
        // system("clear")
        // updateBoard(row1, col1, numRowColumn, board, displayBoard);
        // display(numRowColumn, displayBoard);
	ldr     x0, = msg_ClearScreen
	bl 	system

	ldr     w0, [sp, row1_save]
	ldr     w1, [sp, col1_save]
	ldr	w2, [sp, numRowColumn_save]
	ldr	w3, [sp, boardPtr_save]
	ldr	w4, [sp, displayBoardPtr_save]
	bl	updateBoard

	ldr	w0, [sp, numRowColumn_save]
	ldr	w1, [sp, displayBoardPtr_save]
	bl	display


main_invalidCoord2:

        // printf("Enter the coordinates of the second card:\n");
        ldr     x0, = msg_EnterCoord2
        bl      printf

        mov     x0, sp
        add     x0, x0, userQuitGame_save
        mov     x1, sp
        add     x1, x1, row2_save
        mov     x2, sp
        add     x2, x2, col2_save
        bl      getRowColumn
        cmp     x0, 0
        bne     main_check_user_quit2
main_coord2_error:
        // printf("Input Error: Select a coordinate between %d and %d.\n", 0, maxRowColumn);
        mov     x1, 0
        ldr     x2, [sp, maxRowColumn_save]
        ldr     x0, = msg_CoordError
        bl      printf
        b       main_invalidCoord2              // get input again

main_check_user_quit2:
        ldr     w0, [sp, userQuitGame_save]
        cmp     w0, 0
        bne     main_user_quit_game

	// check if duplicated coord: (row2 == row1 && col2 == col1)
	ldr     w0, [sp, row1_save]
	ldr     w1, [sp, row2_save]
        cmp     w0, w1
	bne	main_coord2_check_range

        ldr     w0, [sp, col1_save]
        ldr     w1, [sp, col2_save]
        cmp     w0, w1
        bne     main_coord2_check_range
	
	ldr     x0, = msg_CoordDuplicated
        bl      printf
	b       main_invalidCoord2              // get input again


main_coord2_check_range:
        // if (row2 < 0 || col2 < 0 || row2 > maxRowColumn || col2 > maxRowColumn)
        ldr     w0, [sp, row2_save]
        cmp     w0, 0
        blt     main_coord2_error

        ldr     w1, [sp, maxRowColumn_save]
        cmp     w0, w1
        bgt     main_coord2_error

        ldr     w0, [sp, col2_save]
        cmp     w0, 0
        blt     main_coord2_error

        ldr     w1, [sp, maxRowColumn_save]
        cmp     w0, w1
        bgt     main_coord2_error

        // if (displayBoard[row2][col2] != -1)
        ldr     x0, [sp, displayBoardPtr_save]
        mov     x1, 0
        mov     x2, 0
        mov     x3, 0
        ldr     w1, [sp, row2_save]
        ldr     w2, [sp, numRowColumn_save]
        mul     w1, w1, w2
        ldr     w3, [sp, col2_save]
        add     w1, w1, w3
        mov     w2, 4                           // 4 bytes
        mul     w1, w1, w2
        add     x0, x0, x1                      // add to the displayBoardPtr + offset
        ldr     w1, [x0]
        cmp     w1, -1
        beq     main_valid_coor2

        ldr     x0, = msg_CardAlreadyMatched
        bl      printf
        beq     main_invalidCoord2

main_valid_coor2:
        mov     w0, 0                           // set coord2 as valid
        str     w0, [sp, invalidCoord2_save]

	//TODO - skipping check if userQuitGame, shouldn't need it
	// system("clear")
        // updateBoard(row1, col1, numRowColumn, board, displayBoard);
        // display(numRowColumn, displayBoard);
        ldr     x0, = msg_ClearScreen
        bl      system

        ldr     w0, [sp, row2_save]
        ldr     w1, [sp, col2_save]
        ldr     w2, [sp, numRowColumn_save]
        ldr     w3, [sp, boardPtr_save]
        ldr     w4, [sp, displayBoardPtr_save]
        bl      updateBoard

        ldr     w0, [sp, numRowColumn_save]
        ldr     w1, [sp, displayBoardPtr_save]
        bl      display

	// if (displayBoard[row1][col1] == displayBoard[row2][col2])
	mov	x0, 0				// clear high bytes
	ldr	w0, [sp, row1_save]
	ldr	w1, [sp, numRowColumn_save]
	mul	w0, w0, w1
	ldr	w1, [sp, col1_save]
	add	w0, w0, w1
	mov	w1, 4
	mul	w0, w0, w1
	ldr	x1, [sp, displayBoardPtr_save]
	add	x2, x1, x0	// w2 = &displayBoard[row1][col1]
	ldr	w3, [x2]	// w3 = displayBoard[row1][col1]

        mov	x0, 0
	ldr     w0, [sp, row2_save]
        ldr     w1, [sp, numRowColumn_save]
        mul     w0, w0, w1
        ldr     w1, [sp, col2_save]
        add     w0, w0, w1
        mov     w1, 4
        mul     w0, w0, w1
        ldr     x1, [sp, displayBoardPtr_save]
        add     x2, x1, x0      // w2 = &displayBoard[row2][col2]
        ldr     w4, [x2]        // w4 = displayBoard[row2][col2]

	cmp 	w3, w4
	bne	main_not_match_clear_board_data
	
	// Match!!
	//    numCardsMatched++;
        //    score += N;
        //    if(numCardsMatched < numCards)
        //       printf("Match!\nScore: %d\nPress any key to continue...\n", score);
        //       scanf("%c", &ch1);

	ldr	w0, [sp, numCardsMatched_save]		// numCardsMatched++
	add	w0, w0, 1
	str	w0, [sp, numCardsMatched_save]

	ldr	w0, [sp, score_save]			// score += n	
	ldr	w1, [sp, nValue_save]
	add	w0, w0, w1
	str	w0, [sp, score_save]

	ldr     w0, [sp, numCardsMatched_save]
	ldr     w1, [sp, numCards_save]
	cmp	w0, w1
	bge	main_won

	ldr     x0, = msg_MatchedResult
	ldr	w1, [sp, score_save]
        bl      printf
        
	// scanf("%c", &ch1);
        ldr     x0, = msg_CharInput
        mov     x1, sp
        add     x1, x1, ch1_save
        bl      scanf

	b 	main_update_display_and_continue

main_not_match_clear_board_data:
        // displayBoard[row1][col1] = -1
        mov     x0, 0                           // clear high bytes
        ldr     w0, [sp, row1_save]
        ldr     w1, [sp, numRowColumn_save]
        mul     w0, w0, w1
        ldr     w1, [sp, col1_save]
        add     w0, w0, w1
        mov     w1, 4
        mul     w0, w0, w1
        ldr     x1, [sp, displayBoardPtr_save]
        add     x2, x1, x0      // w2 = &displayBoard[row1][col1]
        mov	w0, -1
	str     w0, [x2]        // displayBoard[row1][col1] = -1

	// displayBoard[row2][col2] = -1
        mov     x0, 0
        ldr     w0, [sp, row2_save]
        ldr     w1, [sp, numRowColumn_save]
        mul     w0, w0, w1
        ldr     w1, [sp, col2_save]
        add     w0, w0, w1
        mov     w1, 4
        mul     w0, w0, w1
        ldr     x1, [sp, displayBoardPtr_save]
        add     x2, x1, x0      // w2 = &displayBoard[row2][col2]
	mov     w0, -1
        str     w0, [x2]        // displayBoard[row2][col2] = -1

	// distance = findDistance(numRowColumn, board, row1, col1, row2, col2)
	// score--;
	// if (score > 0)
	//    printf("You are %d card away!\nScore: %d\nPress any key to continue...\n", distance, score);
	//    scanf("%c", &ch1)

	ldr	w0, [sp, numRowColumn_save]
	ldr	w1, [sp, boardPtr_save]
	ldr	w2, [sp, row1_save]
	ldr	w3, [sp, col1_save]
	ldr     w4, [sp, row2_save]
        ldr     w5, [sp, col2_save]
	bl	findDistance
	str	w0, [sp, distance_save]

	ldr     w0, [sp, score_save]
	sub	w0, w0, 1		// score--
	str	w0, [sp, score_save]
	cmp	w0, 0
	ble	main_update_display_and_continue

	ldr     x1, [sp, distance_save]
	ldr	x2, [sp, score_save]
        ldr     x0, = msg_NotMatchResult
        bl      printf
        
	// scanf("%c", &ch1);
        ldr     x0, = msg_CharInput
        mov     x1, sp
        add     x1, x1, ch1_save
        bl      scanf

main_update_display_and_continue:
	// system("clear")
        // display(numRowColumn, displayBoard);
        ldr     x0, = msg_ClearScreen
        bl      system

        ldr     w0, [sp, numRowColumn_save]
        ldr     w1, [sp, displayBoardPtr_save]
        bl      display

	b 	main_continue

main_user_quit_game:
	ldr	w1, [sp, score_save]
	ldr     x0, = msg_QuitScore
        bl      printf
	b 	main_end

main_game_over:
	ldr     w1, [sp, score_save]
        ldr     x0, = msg_GameOverScore
        bl      printf
	b	main_end

main_won:
        ldr     w1, [sp, score_save]
        ldr     x0, = msg_WonScore
        bl      printf
	b	main_end

main_end:
	mov	x0, sp
	add	x0, x0, playerName_save
	ldr	w1, [sp, score_save]
	bl	logFile
	
        ldr     x0, [sp, boardPtr_save]
        bl      free					// free board memory

        ldr     x0, [sp, displayBoardPtr_save]
	bl	free					// free displayBoard memory

	b 	end

err1:	// not enough arguments
        ldr	x0, = msg_InputErr1
        bl 	printf
	b   	end

err2:
        ldr     x0, = msg_InputErr2
        bl      printf
	b	end

end:	//sub sp, sp, -16			
	// sub sp, sp, alloc
        ldp x29, x30, [sp], dealloc
        ret


