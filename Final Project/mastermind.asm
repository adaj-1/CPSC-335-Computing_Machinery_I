// CPSC 355 Mastermind Final Project
// Jada Li
// UCID: 30016807

// global variables with initialization
.data
startUpRow:		.word	0	// int startUpRow = 0; 			// count rows for buffer
screenCurrentRow:	.word	0	// int screenCurrentRow=0;		// count rows for buffer
gameOverRow:		.word	0	// int gameOverRow = 0;
startGame:		.word	0	// bool startGame;
checkScore:		.word	0	// bool checkScore;

// allocates memory for global variables
.bss
startUpOutput:		.skip	10000	// char g_startUpOutput[100][100];      // for game startup outputs
screenOutput:		.skip	3200	// char screenOutput[40][80];           // for in game screen outputs
gameOverOutput:         .skip   10000   // char gameOverOutput[100][100];       // for end game screen outputs


.text

define(MY_POS_INFINITY, 0x7f800000)
define(MY_NEG_INFINITY, 0xff800000)

string_Infinity:	.string	"INFINITY"
string_NegInfinity:	.string "-INFINITY"
string_Input_Error_N:	.string "Input Error: N must be greater than or equal to 1.\n"
string_Input_Error_C:	.string "Input Error: C must be greater than or equal to 5.\n" 
string_Input_Error_M:   .string "Input Error: M must be greater than or equal to C.\n"
string_Input_Error_R:   .string "Input Error: R must be greater than or equal to 1.\n"
string_Input_Error_T:   .string "Input Error: T must be greater than 0 minutes.\n"
string_Input_Error:     .string "Input Error: \n"


string_Input_Message:   .string "Please enter Player Name, N, M, C, R, and T values\n"
string_Input_Scanf:	.string "%s %d %d %d %d %d"

string_Input_Integer:	.string "%d"
string_Input_String:	.string "%s"
string_Input_3Strings: 	.string "%s %s %s"		// reading from log file
string_Input_LogFile:	.string "%s %f %s"		// writing to log file
string_Input_Str_Float_Str: 	.string "%s %f %s\n"
string_Input_GameMode:	.string "Please select a mode: Play (0) or Test (1)\n"
string_Input_GameMode_Error:	.string "Input Error: Please enter 1 or 0.\n"

string_Input_EnterGuess:	.string "Enter your guess below:\n"
string_InputNumTopScores:	.string	"Enter number of Top Scores to display:\n"
string_InputNumBottomScores:	.string	"Enter number of Bottom Scores to display:\n"


string_TimeFormat:	.string "%02d:%02d"
string_Cracked:		.string "Cracked!\n"
string_TrialsExceeded:	.string "Trials exceeded.\n"
string_TimeExceeded:	.string "Time exceeded.\n"
string_FinalScore:	.string "Final Score: %.2f\n"

string_RunTestMode:	.string "Hello %s!\nRunning Mastermind in test mode\n"
string_RunPlayMode:	.string "Hello %s!\nRunning Mastermind in play mode\n"

string_HiddenCode:	.string "Hidden code is: "
string_StartCracking:	.string "Start cracking...\n"

string_Display_Char:	.string " %c "
string_CR:		.string "\n"
string_Header:		.string "  B   W   R   S   T\n"
string_Dash:		.string "- "

string_Display_Hints_1:        	.string "%s  B  W  R  S    T\n"
string_Display_Hints_2:		.string "%s %2d %2d %2d  %4.2f %s\n"

//TODO - remove
string_Clear: 		       	.string ""
//string_Clear:                   .string "clear"

string_Space:			.string " "

string_LogFilename:		.string "mastermind.log"
string_Append:			.string "a+"
string_ReadOnly:		.string "r"
string_ShowInfinity:		.string "%s -INFINITY INFINITY\n"
string_LogScores:		.string "%s %f %s\n"
string_TimeHMS:			.string "%H-%M-%S"
string_NameWithTime:		.string "%s_%s"
string_TimeFilename:		.string	"%s.txt"

string_TopBottomScore:		.string	"Top Scores (0) or Bottom Scores (1)\n"
string_ErrorFileEmpty:		.string "Error! File is Empty.\n"
string_DisplayCommands:		.string	"Start Game (#) or Quit Game ($) or Check Top/Bottom Scores (!)\n"

//* Description: struct to hold all user input parameters
// struct UserSetup
s_UserSetup_playerName_offset 	= 0	// size 24
s_UserSetup_rows_offset		= 24	// size 4
s_UserSetup_columns_offset	= 28	// size 4
s_UserSetup_numOfColours_offset = 32	// size 4
s_UserSetup_maxTrials_offset	= 36	// size 4
s_UserSetup_maxTime_offset	= 40	// size 4
s_UserSetup_mode_offset		= 44	// size 4
s_UserSetup_total_size		= 48	

//* Description: struct to hold all time variables for game
// struct GameTime
s_GameTime_startTime_offset	= 0	// size 8; long int
s_GameTime_timeRemaining_offset	= 8	// size 8; long int
s_GameTime_hours_offset		= 16	// size 4
s_GameTime_minutes_offset	= 20	// size 4
s_GameTime_seconds_offset	= 24	// 4
s_GameTime_total_size		= 28

//* Description: struct to hold all scores for game
// struct AllScores
s_AllScores_B_offset		= 0	// size 4
s_AllScores_W_offset		= 4	// size 4
s_AllScores_numOfTrials_offset	= 8	// size 4
s_AllScores_cumScore_offset	= 12	// size 8; double
s_AllScores_finalScore_offset	= 20	// size 8; double
s_AllScores_total_size		= 28


.balign 4                               // ensures instructions are properly aligned
.global main

//* Description: Random number generator
//*
//* @param	lowerBound 	for the random number generator
//*		upperBound 	for the random number generator
//* 		neg			did not do as Prof said this was unnecessary in lecture
//* @return random integer within the bounds

//int randomNum (int minimum, int maximum)
//      w0 = minimum
//      w1 = maximum
randomNum:
        minimum_size = 4                                //
        maximum_size = 4
        total_size = minimum_size + maximum_size
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        minimum_save = 16                       // sp offset
        maximum_save = 20                       // offset from minimum
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     w0, [sp, minimum_save]
        str     w1, [sp, maximum_save]

        // srand(time(0))       // seed a random number generator
        //mov     x0, 0
        //bl      time
        //bl      srand

        // return rand() % (maximum + 1 - minimum) + minimum;
	bl      rand            // w0 contains returned random value
        ldr     w1, [sp, maximum_save]
        mov     w2, 1
        add     w1, w1, w2                      // w1 = maximum + 1
        ldr     w3, [sp, minimum_save]
        sub     w1, w1, w3                      // w1 = w1 - minimum
        sdiv    w2, w0, w1                      // w2 = (rand / w1) * w1
        mul     w2, w2, w1                      // modding and multiplying like in BCD assignment
        sub     w0, w0, w2                      // rand - w2 to obtain the remainder
        add     w0, w0, w3                      // + minimum to put number in max/min range

        ldp     x29, x30, [sp], dealloc
        ret

//* Description:  returns a letter (colour) based on an integer value n
//*
//* @param 	n			to randomize colour select
//*
//* @return	newColour	randomized colour
// char colour(int n)

colour:
	add	w0, w0, 65	// convert # to A-Z ASCII by adding 'A' to represent color
	ret

//* Description: to determine time elapsed
//*
//* @param	maxTimeSec	time specified by user in seconds
//* 			gameTime	struct to store changes to time
// void findTime(int maxTimeSec, struct GameTime *gameTime)

findTime:
        maxTimeSec_size = 4
	gameTimePtr_size = 8
        currentTime_size = 8
	tempTime_size = 8				// local variable
	total_size = 28				// local variable
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        maxTimeSec_save = 16
        gameTimePtr_save = 20
	currentTime_save = 28
	tempTime_save = 36
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

	str	w0, [sp, maxTimeSec_save]
	str	x1, [sp, gameTimePtr_save]

	// time(&currentTime);	
	mov	x0, sp				// x0 = &currentTime
	add	x0, x0, currentTime_save	// add offset from currentTime_save
	bl 	time

	// time_t tempTime = currentTime - gameTime->startTime;
	ldr 	x0, [sp, gameTimePtr_save]
	add	x0, x0, s_GameTime_startTime_offset
	ldr	x1, [x0]			// x1 = gameTime->startTime
	ldr     x0, [sp, currentTime_save]
	sub	x0, x0, x1
	str	x0, [sp, tempTime_save]

	// gameTime->timeRemaining = maxTimeSec - tempTime;	
	ldr	w0, [sp, maxTimeSec_save]
	ldr	w1, [sp, tempTime_save]	
	cmp	w0, w1
	b.le	findTime_1	// to avoid negative value
	sub	w0, w0, w1
	b	findTime_2
findTime_1:
	mov	w0, 0			// zero out timeRemaining
findTime_2:
	ldr     x1, [sp, gameTimePtr_save]
        add     x1, x1, s_GameTime_timeRemaining_offset
	str	w0, [x1]		// store timeRemaining

        ldp     x29, x30, [sp], dealloc	
	ret

//* Description: converts timeRemaining into a mm:ss format to be used for log and transcripe functions
//*
//* @param	timeInSec	timeRemaining in seconds
//* 		timeStr		formatted time in string
// void timeToString(long int timeInSec, char *timeStr)

timeToString:
        timeInSec_size = 8
        timeStrPtr_size = 8
        minute_size = 4				// local variable
        second_size = 4                         // local variable
        total_size = 24
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        timeInSec_save = 16
        timeStrPtr_save = 24
        minute_save = 32
        second_save = 36
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     x0, [sp, timeInSec_save]
        str     x1, [sp, timeStrPtr_save]

	// if (timeInSec == MY_POS_INFINITY)
	//    strcpy(timeStr, "INFINITY");
	
	mov	x1, MY_POS_INFINITY
	cmp	x0, x1
	b.ne	timeToString_notPosInfinity
	ldr	x0, [sp, timeStrPtr_save]
	ldr	x1, =string_Infinity
	bl	strcpy
	b	timeToString_end

timeToString_notPosInfinity:
	// int minutes = timeInSec / 60;
	// int seconds = timeInSec - (minutes * 60);
	// sprintf(timeStr, "%02d:%02d", minutes, seconds)
	ldr     x4, [sp, timeInSec_save]	
	mov	x5, 60
	sdiv	x2, x4, x5		// x2 = minutes = timeInSec / 60 (modding)

	mul	x3, x2, x5		// calculating remainder
	sub	x3, x4, x3		// x3 = remaining secs

	ldr     x0, [sp, timeStrPtr_save]
	ldr	x1, =string_TimeFormat
	bl	sprintf
	
timeToString_end:
        ldp     x29, x30, [sp], dealloc
        ret


//* Description: initializes code, time, scores, and mode
//*
//* @param	setup		prints starting messages and used to initialize code
//*		code		creates randomized code
//*		*gameTime	resets gameTime if game is restarted
//*		*scores		resets scores if game is restarted
// void initializeGame (struct UserSetup setup,
//			 char code[setup.rows][setup.columns],
//			 struct GameTime *gameTime,
//			 struct AllScores *scores)

initializeGame:
        setupPtr_size = 8 	
        codePtr_size = 8
	gameTimePtr_size = 8
	scoresPtr_size = 8
	tempTime_size = 8
        x19_size = 8                            // allocate space to store register
        x20_size = 8         
        x21_size = 8 
	x22_size = 8
	x23_size = 8
	x24_size = 8
	total_size = 72
        alloc = -(16 + total_size) & -16 
        dealloc = -alloc
        setupPtr_save = 16                            // sp offset
        codePtr_save = setupPtr_save + 8
        gameTimePtr_save = codePtr_save + 8
        scoresPtr_save = gameTimePtr_save + 8
        tempTime_save = scoresPtr_save + 8
        x19_save = tempTime_save + 8
        x20_save = x19_save + 8
        x21_save = x20_save + 8
        x22_save = x21_save + 8
	x23_save = x22_save + 8	
	x24_save = x23_save + 8

        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

	str	x0, [sp, setupPtr_save]
	str     x1, [sp, codePtr_save]
	str     x2, [sp, gameTimePtr_save]
	str     x3, [sp, scoresPtr_save]

        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]
        str     x23, [sp, x23_save]
        str     x24, [sp, x24_save]

	// time(&gameTime->startTime);				// time stamps start of game
	ldr     x0, [sp, gameTimePtr_save]
	add	x0, x0, s_GameTime_startTime_offset
	bl	time
	
	//* Initializing struct gameTime */
	// gameTime->timeRemaining = 0;
	// gameTime->hours = 0;
	// gameTime->minutes = 0;
	// gameTime->seconds = 0;
	ldr	x19, [sp, gameTimePtr_save]
	mov	x0, 0
	str	x0, [x19, s_GameTime_timeRemaining_offset]	// long int
	str	w0, [x19, s_GameTime_hours_offset]
	str	w0, [x19, s_GameTime_minutes_offset]
	str	w0, [x19, s_GameTime_seconds_offset]

	//* Initializing struct scores */
	//scores->B = 0;
	//scores->W = 0;
	//scores->numOfTrials = 0;
	//scores->cumScore = 0;
	//scores->finalScore = 0;
	ldr     x19, [sp, scoresPtr_save]
	mov     x0, 0
	str     w0, [x19, s_AllScores_B_offset]
	str     w0, [x19, s_AllScores_W_offset]
	str     w0, [x19, s_AllScores_numOfTrials_offset]
	scvtf	d0, w0						// convert to floating point
	str     d0, [x19, s_AllScores_cumScore_offset]	
	str     d0, [x19, s_AllScores_finalScore_offset]

	// Generating random seed for game
	// time_t tempTime;
	// srand( (unsigned) time(&tempTime) );
	mov	x0, sp
	add	x0, x0, tempTime_save		// &tempTime
	bl	time				// time returns in x0
// TODO - uncomment fixed seed	
//	bl	srand

	//* resets display buffers */
	// screenCurrentRow = 1;
	// startUpRow = 0;
	// gameOverRow = 0;
	mov	w0, 1
	ldr	x1, =screenCurrentRow
	str	w0, [x1]

        mov     w0, 0
        ldr     x1, =startUpRow
        str     w0, [x1]

        mov     w0, 0
        ldr     x1, =gameOverRow
        str     w0, [x1]

	// if (setup.mode == 1)
	//   sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
	//   printf("Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
	// else
	//   sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
	//   printf("Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
        ldr     x0, [sp, setupPtr_save]
 	add	x0, x0, s_UserSetup_mode_offset
	ldr	w1, [x0]
	cmp	w1, 1
	b.ne	initialize_showPlayMode

	// initial testMode
	//   sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_RunTestMode
        ldr     x2, [sp, setupPtr_save]
        add     x2, x2, s_UserSetup_playerName_offset
        bl      sprintf

	//   printf("Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
	ldr	x0, =string_RunTestMode
        ldr     x1, [sp, setupPtr_save]
        add     x1, x1, s_UserSetup_playerName_offset
	bl	printf
	b	initialize_generateCode

initialize_showPlayMode:
 	//   sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_RunPlayMode
        ldr     x2, [sp, setupPtr_save]
        add     x2, x2, s_UserSetup_playerName_offset
        bl      sprintf

	//   printf("Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
        ldr     x0, =string_RunPlayMode
        ldr     x1, [sp, setupPtr_save]
        add     x1, x1, s_UserSetup_playerName_offset
        bl      printf

initialize_generateCode:
	//* generates randomized colour code and fills code array */
	// for (int i = 0; i < setup.rows; i++ )
	//    for (int j = 0; j < setup.columns; j++)
	//	  int randNum = randomNum( 0, setup.numOfColours - 1);	// upper/lower bound based on user input
	//	  code[i][j] = colour(randNum);					
	ldr     x0, [sp, setupPtr_save]		// x21 = setup.rows
        add     x0, x0, s_UserSetup_rows_offset
        ldrsw   x21, [x0]

        ldr     x0, [sp, setupPtr_save]		// x22 = setup.columns
        add     x0, x0, s_UserSetup_columns_offset
        ldrsw   x22, [x0]                     

	ldr     x0, [sp, setupPtr_save]         // x23 = setup.setup.numOfColours - 1
        add     x0, x0, s_UserSetup_numOfColours_offset
        ldrsw   x23, [x0]	// sign extend to the x register
        sub     x23, x23, 1

// generates randomized colour code and fills code array
	mov     x19, 0                        // x19 = i = 0
initialize_code_i:
        mov     x20, 0                        // x20 = j = 0
initialize_code_j:
// filling code with randomized colours
	mov	x0, 0
	mov	x1, x23
	bl	randomNum
	bl	colour
	mov	x24, x0				// x24 = colour(randNum)
	//TODO
	mul	x0, x19, x22			// x0 = i*columns
	add	x0, x0, x20			// code = i*columns + j
	ldr	x1, [sp, codePtr_save]		// x1 = code[i][j]
	add	x0, x0, x1
	str	x24, [x0]			// code[i][j] = colour(randNum)

	add	x20, x20, 1			// j++
	cmp	x20, x22			// check j < setup.columns	
	b.lt	initialize_code_j

	add	x19, x19, 1			// i++
	cmp	x19, x21
	b.lt	initialize_code_i

initialize_setupMode:
	// if (setup.mode == 1)
	ldr     x0, [sp, setupPtr_save]
	add	x0, x0, s_UserSetup_mode_offset
	ldr	w1, [x0]
	cmp	w1, 1
	b.ne	initialize_startCracking

	// sprintf(startUpOutput[startUpRow++],"Hidden code is: ");	
	// printf("Hidden code is: ");
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_HiddenCode
        bl      sprintf			// to transcripe game

        ldr     x0, =string_HiddenCode
        bl      printf			// to print game in console

	// displays hidden code for test mode 
	// for (int i = 0; i < setup.rows; i++ )
	//    for (int j = 0; j < setup.columns; j++)
	//        sprintf(startUpOutput[startUpRow++]," %c ", code[i][j]);
	//	  printf(" %c ", code[i][j]);
	//    sprintf(startUpOutput[startUpRow++],"\n");
	//    printf("\n");
        ldr     x0, [sp, setupPtr_save]         // x21 = setup.rows
        add     x0, x0, s_UserSetup_rows_offset
        ldrsw   x21, [x0]

        ldr     x0, [sp, setupPtr_save]         // x22 = setup.columns
        add     x0, x0, s_UserSetup_columns_offset
        ldrsw   x22, [x0]

// TODO - tbd if should keep CR
	// for (int i = 0; i < setup.rows; i++ )
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_CR
        bl      sprintf
	
        ldr     x0, =string_CR
        bl      printf

        mov     x19, 0                        // x19 = i = 0
initialize_displaycode_i:
        mov     x20, 0                        // x20 = j = 0
initialize_displaycode_j:
        mul     x0, x19, x22                    // x0 = i*columns
        add     x0, x0, x20                     // code = i*columns + j
        ldr     x1, [sp, codePtr_save]          // x1 = code[i][j]
        add     x0, x0, x1
        ldrsb   x23, [x0]                       // x23 = code[i][j]	reading 1 byte (char)

 	// sprintf(startUpOutput[startUpRow++]," %c ", code[i][j]);
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_Display_Char
	mov	x2, x23
        bl      sprintf

	// printf(" %c ", code[i][j]);
	mov	x1, x23
	ldr	x0, =string_Display_Char
	bl	printf

        add     x20, x20, 1                     // j++
        cmp     x20, x22                        // check j < setup.columns
        b.lt    initialize_displaycode_j

	// sprintf(startUpOutput[startUpRow++],"\n")
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_CR
        bl      sprintf
	
	//    printf("\n");
	ldr	x0, =string_CR
	bl	printf

        add     x19, x19, 1                     // i++
        cmp     x19, x21
        b.lt    initialize_displaycode_i

initialize_startCracking:
	// sprintf(startUpOutput[startUpRow++],"Start cracking...\n");
	// printf("Start cracking...\n");
        ldr     x0, =startUpOutput
        ldr     x1, =startUpRow
        mov     x2, 0
        ldr     w2, [x1]
        mov 	x3, 100
	mul	x3, x2, x3
	add     x0, x0, x3              // &startUpOutput[startUpRow]
        add     w2, w2, 1
        str     w2, [x1]                // startUpRow++
        ldr     x1, =string_StartCracking
        bl      sprintf

        ldr     x0, =string_StartCracking
        bl      printf


	//* prints initial user interface */
	// for (int i = 0; i < setup.rows; i++ )
	//	for (int j = 0; j < setup.columns; j++)
	//		printf("- ");
	//	if(i == 0)
	//		printf("  B   W   R   S   T\n");
	//	printf("\n");
        mov     x19, 0                        // x19 = i = 0
initialize_displayHeader_i:
        mov     x20, 0                        // x20 = j = 0
initialize_displayHeader_j:
        ldr	x0, =string_Dash
	bl	printf
        add     x20, x20, 1                     // j++
        cmp     x20, x22                        // check j < setup.columns
        b.lt    initialize_displayHeader_j

initialize_displayHeader1:
	add     x19, x19, 1                     // i++
        cmp     x19, x21
        b.lt    initialize_displayHeader_i

        ldr     x0, =string_Header
        bl      printf
        ldr     x0, =string_CR
        bl      printf

initialize_end:
        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
        ldr     x23, [sp, x23_save]
        ldr     x24, [sp, x24_save]
        ldp     x29, x30, [sp], dealloc
	ret;

//*Description: prints the hints
//*
//* @param	B is the num of colours that are correct and in the right slot
//* 		W is  the num of colours that are correct but in the wrong slot
//* 		R is the num of trials
//* 		S is the cumulative score
//* 		T is the remaining time
// void displayHints(struct UserSetup setup,
//                        char userGuess[setup.rows][setup.columns],
//			  struct GameTime gameTime,
//			  struct AllScores score)

displayHints:
        setupPtr_size = 8
        userGuessPtr_size = 8
        gameTimePtr_size = 8
        scoresPtr_size = 8
        userInputSpaceStr_size = 128
	userInputStr_size = 128
	timeStr_size = 24
        x19_size = 8                            // allocate space to store register
        x20_size = 8
        x21_size = 8
        total_size = 56 + 256 + 24
        alloc = -(16 + total_size) & -16         // 0 size for testing only
        dealloc = -alloc
        setupPtr_save = 16                            // sp offset
        userGuessPtr_save = setupPtr_save + 8
        gameTimePtr_save = userGuessPtr_save + 8
        scoresPtr_save = gameTimePtr_save + 8
        userInputSpaceStr_save = scoresPtr_save + 8
	userInputStr_save = userInputSpaceStr_save + 128
        timeStr_save = userInputStr_save + 128
	x19_save = timeStr_save + 24
        x20_save = x19_save + 8
        x21_save = x20_save + 8

        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     x0, [sp, setupPtr_save]
        str     x1, [sp, userGuessPtr_save]
        str     x2, [sp, gameTimePtr_save]
        str     x3, [sp, scoresPtr_save]

        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

	//char userInputSpaceStr[128];		// to hold cracked code dashes
	//char userInputStr[128];		// to hold userGuess

	//userInputSpaceStr[0] = '\0';		// initialize to null
	//userInputStr[0] = '\0';		// initialize to null
	mov	x0, 0
	strb	w0, [sp, userInputSpaceStr_save]
	strb	w0, [sp, userInputStr_save]

	//* to reprint user guess with hints */	
	//for (int i=0; i < setup.rows*setup.columns; i++)
	//	strcat( userInputSpaceStr, "- ");
	//	userInputStr[2*i] = userGuess[0][i];
	//	userInputStr[2*i+1] = ' ';
	//	userInputStr[2*i+2] = '\0';
	mov	x19, 0					// x19 = i = 0
	ldr     x0, [sp, setupPtr_save]
	add	x0, x0, s_UserSetup_rows_offset
	ldrsw	x1, [x0]
        ldr     x0, [sp, setupPtr_save]
        add     x0, x0, s_UserSetup_columns_offset
        ldrsw   x2, [x0]
	mov	w20, 0
	mul	w20, w1, w2				// w20 = setup.rows*setup.columns
displayHints_loop1:
	add	x0, sp, userInputSpaceStr_save
	ldr	x1, =string_Dash
	bl	strcat

	ldr     x0, [sp, userGuessPtr_save] 
        add     x0, x0, x19
        ldrsb   w21, [x0]				// w21 = userGuess[0][i]

	add     x0, sp, userInputStr_save
	add	x0, x0, x19
	add     x0, x0, x19
	strb	w21, [x0]		// userInputStr[2*i] = userGuess[0][i]...(2*i to account for spaces)

	add	x0, x0, 1 
	mov	w1, ' '
	strb	w1, [x0]				// userInputStr[2*i+1] = ' '

        add     x0, x0, 1
        mov     w1, 0					
        strb    w1, [x0]				// userInputStr[2*i+2] = 0

	add	x19, x19, 1		// i++
	cmp	w19, w20		// if i < setup.rows*setup.columns
	b.lt	displayHints_loop1

	// /* convert time in sec to mm:ss format  */
	//char timeStr[20];
	//timeToString(gameTime.timeRemaining, timeStr);

	ldr	x1, [sp, gameTimePtr_save]
	add	x1, x1, s_GameTime_timeRemaining_offset 
	ldr	x0, [x1]

	add	x1, sp, timeStr_save
	bl	timeToString

	//* generate screenOuput for the last results */
	// sprintf(screenOutput[0], "%s  B  W  R  S    T\n", userInputSpaceStr);
	// sprintf(screenOutput[screenCurrentRow++], "%s %2d %2d %2d  %4.2f %s\n", userInputStr,
	//									score.B,
	//  								    	score.W,
	//									score.numOfTrials,
	//									score.cumScore,
	// 									timeStr);
	ldr	x0, =screenOutput
	ldr	x1, =string_Display_Hints_1
	add	x2, sp, userInputSpaceStr_save
	bl	sprintf

	ldr	x0, =screenCurrentRow
	ldrsw	x0, [x0]
	mov	x1, 80			// screenOutput[40][80]
	mul	x0, x0, x1
	ldr	x1, =screenOutput
	add	x0, x0, x1 		// x0 = screenOutput[screenCurrentRow]

	ldr	x1, =string_Display_Hints_2

	add	x2, sp, userInputStr_save

	ldr	x3, [sp, scoresPtr_save]
	add	x3, x3, s_AllScores_B_offset
	ldr	w3, [x3]

        ldr     x4, [sp, scoresPtr_save]
        add     x4, x4, s_AllScores_W_offset
	ldr	w4, [x4]

	ldr     x5, [sp, scoresPtr_save]
        add     x5, x5, s_AllScores_numOfTrials_offset
        ldr     w5, [x5]

	ldr     x6, [sp, scoresPtr_save]
        add     x6, x6, s_AllScores_cumScore_offset
        ldr     d0, [x6]

	add	x6, sp, timeStr_save
	bl	sprintf 

        ldr     x1, =screenCurrentRow
        ldr     w0, [x1]
	add	w0, w0, 1
	str	w0, [x1]

	// system("clear");
	ldr	x0, =string_Clear
	bl	system

	// print all hints for this game
	// for (int i = 0; i < screenCurrentRow; i++)
	//	printf( "%s", screenOutput[i] );
	mov	w19, 0				// x19 = i = 0
        ldr     x0, =screenCurrentRow
        ldrsw   x20, [x0]			// x20 = screenCurrentRow
displayHints_loop:
        mov     x1, 80                  	// column size 80, screenOutput[40][80]
        mul     x0, x19, x1
        ldr     x1, =screenOutput		 
	add	x1, x1, x0			// screenOutput[i]

	ldr	x0, =string_Input_String
	bl	printf
	add	w19, w19, 1
	cmp	w19, w20
	b.lt	displayHints_loop

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp     x29, x30, [sp], dealloc
	ret


//* Description: finding B and W scores
//*
//* @param	setup		provides user input parameters
//* 		code		holds code
//* 		userGuess	holds user guess
//* 		*score		updates score
// void findBW(struct UserSetup setup,
//		char code[setup.rows][setup.columns],
//		char userGuess[setup.rows][setup.columns],
//		struct AllScores *scores)

findBW:
        setupPtr_size = 8
        codePtr_size = 8
        userGuessPtr_size = 8
        scoresPtr_size = 8
	tmpCodePtr_size = 8
	tmpUserGuessPtr_size = 8
        x19_20_21_22_23_24_total_size = 48
        total_size = 48 + 48

        alloc = -(16 + total_size) & -16
        dealloc = -alloc

        setupPtr_save = 16
        codePtr_save = 24
        userGuessPtr_save = 32 
        scoresPtr_save = 40
	tmpCodePtr_save = 48
	tmpUserGuessPtr_save = 56
        x19_save = 64
        x20_save = 72
        x21_save = 80
        x22_save = 88
	x23_save = 96
	x24_save = 104


        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]
        str     x23, [sp, x23_save]
        str     x24, [sp, x24_save]

        str     x0, [sp, setupPtr_save]
        str     x1, [sp, codePtr_save]
        str     x2, [sp, userGuessPtr_save]
        str     x3, [sp, scoresPtr_save]

        ldr     x0, [sp, setupPtr_save] 
	add	x0, x0,	s_UserSetup_rows_offset
	ldrsw	x21, [x0]				// x21 = setup.rows

	ldr	x0, [sp, setupPtr_save]
	add	x0, x0, s_UserSetup_columns_offset
	ldrsw	x22, [x0]				// x22 = setup.columns

        mul     x0, x21, x22
        bl      malloc
        str     x0, [sp, tmpCodePtr_save]

	mul     x0, x21, x22
        bl      malloc
        str     x0, [sp, tmpUserGuessPtr_save]

	// score->B = 0;
	// score->W = 0;
	ldr     x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_B_offset
	mov	w1, 0
	str	w1, [x0]

        ldr     x0, [sp, scoresPtr_save]
        add     x0, x0, s_AllScores_W_offset
        mov     w1, 0
        str     w1, [x0]

	//* copying code to tmpcode */
	// for (int i = 0; i < setup.rows; i++)
	//	for (int j = 0; j < setup.columns; j++)
	//		tmpCode[i][j] = code[i][j];
	//		tmpUserGuess[i][j] = userGuess[i][j];
	mov	x19, 0					// x19 = i = 0
findBW_loop1_i:
	mov	x20, 0					// x20 = j = 0
findBW_loop1_j:
	mul	x3, x19, x22				// i*setup.columns
	add	x3, x3, x20				// i*setup.columns + j

	ldr	x0, [sp, tmpCodePtr_save]
	add	x0, x0, x3				// &tmpCode[i][j]
	ldr	x1, [sp, codePtr_save]		
	add	x1, x1, x3				// &code[i][j]
	ldrsb	w4, [x1]
	strb	w4, [x0]

        ldr     x0, [sp, tmpUserGuessPtr_save]
        add     x0, x0, x3                              // &tmpUserGuess[i][j]
        ldr     x1, [sp, userGuessPtr_save]
        add     x1, x1, x3                              // &userGuess[i][j]
        ldrsb   w4, [x1]
        strb    w4, [x0]

	add	x20, x20, 1
	cmp	x20, x22
	b.lt	findBW_loop1_j				// j < setup.columns

	add	x19, x19, 1
	cmp	x19, x21				// i < setup.rows
	b.lt	findBW_loop1_i

	//* calculating B score */
	// for (int i = 0; i < setup.rows; i++)
	//	for (int j = 0; j < setup.columns; j++)
	//		if (tmpUserGuess[i][j] == tmpCode[i][j])
	//			score->B++;
	//			tmpUserGuess[i][j] = '0';
	//			tmpCode[i][j] = '1';
        mov     x19, 0                                  // x19 = i = 0
findBW_loop2_i:
        mov     x20, 0                                  // x20 = j = 0
findBW_loop2_j:
        mul     x3, x19, x22                            // i*setup.columns
        add     x3, x3, x20                             // i*setup.columns + j

        ldr     x0, [sp, tmpCodePtr_save]
        add     x0, x0, x3                              // &tmpCode[i][j]
        ldr     x1, [sp, tmpUserGuessPtr_save]
        add     x1, x1, x3                              // &tmpUserGuess[i][j]
        ldrsb   w4, [x1]
        ldrsb   w5, [x0]
	cmp	w4, w5
	b.ne	findBW_loop2_continue

        mov     w2, '0'
        strb    w2, [x1]                            // tmpUserGuess[i][j] = '0'...set to 0 to avoid future match
        mov     w2, '1'
        strb    w2, [x0]                            // tmpCode[i][j] = '1'...set to 1 to avoid future match

        ldr     x0, [sp, scoresPtr_save]	    // score->B++
        add     x0, x0, s_AllScores_B_offset
        ldr	w1, [x0]
	add	w1, w1, 1
	str	w1, [x0]			    // update offset	

findBW_loop2_continue:
        add     x20, x20, 1
        cmp     x20, x22
        b.lt    findBW_loop2_j          // j < setup.columns

        add     x19, x19, 1
        cmp     x19, x21                // i < setup.rows
        b.lt    findBW_loop2_i

	//* calculating W score */
	// for (int i = 0; i < setup.rows; i++)
	//	for (int j = 0; j < setup.columns; j++)
	//		char colour = tmpUserGuess[i][j];
	//		for (int x = 0; x < setup.rows; x++)
	//			for (int y = 0; y < setup.columns; y++)
	//				if (colour == tmpCode[x][y])
	//					score->W++;
	//					tmpUserGuess[i][j] = '0';
	//					tmpCode[x][y] = '1';
        mov     x19, 0                                  // x19 = i = 0
findBW_loop3_i:
        mov     x20, 0                                  // x20 = j = 0
findBW_loop3_j:
        mul     x6, x19, x22                            // i*setup.columns
        add     x6, x6, x20                             // x6 = i*setup.columns + j

	// char colour = tmpUserGuess[i][j];	
        ldr     x0, [sp, tmpUserGuessPtr_save]
        add     x0, x0, x6                              // &tmpUserGuess[i][j]
        ldrsb   w7, [x0]				// w7 = colour = tmpUserGuess[i][j]
        
	mov	x23,0					// x23 = x = 0
findBW_loop3_x:
	mov	x24, 0					// x24 = y = 0
findBW_loop3_y:
	//if (colour == tmpCode[x][y])
        mul     x5, x23, x22                            // x*setup.columns
        add     x5, x5, x24                             // x5 = x*setup.columns + y
        ldr     x4, [sp, tmpCodePtr_save]
        add     x4, x4, x5                              // &tmpCode[x][y]
        ldrsb   w0, [x4]                                
	cmp	w7, w0				// if (colour == tmpCode[x][y])...checks one colour at a time
	b.ne	findBW_loop3_continue

        mov     w2, '1'
        strb    w2, [x4]                            // tmpCode[x][y] = '1'...set to 1 to avoid future match

	ldr     x0, [sp, tmpUserGuessPtr_save]
        add     x0, x0, x6                              
       	mov	w2, '0'
	strb    w2, [x0]                           // tmpUserGuess[i][j] ='0'...set to 0 to avoid future match
	
        ldr     x0, [sp, scoresPtr_save]           // score->W++
        add     x0, x0, s_AllScores_W_offset
        ldr     w1, [x0]
        add     w1, w1, 1
        str     w1, [x0]

findBW_loop3_continue:
	add	x24, x24, 1
	cmp	x24, x22
	b.lt    findBW_loop3_y          // y < setup.columns

       //TODO  add     x23, x19, 1
        add	x23, x23, 1
	cmp     x23, x21                // x < setup.rows
        b.lt    findBW_loop3_x

        add     x20, x20, 1
        cmp     x20, x22
        b.lt    findBW_loop3_j          // j < setup.columns

        add     x19, x19, 1
        cmp     x19, x21                // i < setup.rows
        b.lt    findBW_loop3_i

findBW_end:
	ldr     x0, [sp, tmpCodePtr_save]
	bl	free

	ldr     x0, [sp, tmpUserGuessPtr_save]
	bl	free

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
        ldr     x23, [sp, x23_save]
        ldr     x24, [sp, x24_save]
        ldp x29, x30, [sp], dealloc

	ret

//* Description: returns overall score
//*
//* @param	setup		used to calculate scores
//*		code		used to check user guess
//*		userGuess	checks user guess
//*		*gameTime	updates remaining time
//*		*score		to update scores
//*
//* @return	false if	(1) code is cracked
//* 				(2) time exceeded
//*				(3) trials exceeded
// bool calculateScore(struct UserSetup setup,
//			char code[setup.rows][setup.columns],
//			char userGuess[setup.rows][setup.columns],
//			struct GameTime *gameTime,
//			struct AllScores *score)

calculateScore:
        setupPtr_size = 8
        codePtr_size = 8
        userGuessPtr_size = 8
	gameTimePtr_size = 8
        scoresPtr_size = 8
        x19_20_21_total_size = 24
        total_size = 40 + 24

        alloc = -(16 + total_size) & -16  
        dealloc = -alloc

        setupPtr_save = 16
        codePtr_save = 24
	userGuessPtr_save = 32
        gameTimePtr_save = 40
        scoresPtr_save = 48
        x19_save = 56
        x20_save = 64
        x21_save = 72

        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        str     x0, [sp, setupPtr_save]
        str     x1, [sp, codePtr_save]
	str     x2, [sp, userGuessPtr_save]
        str     x3, [sp, gameTimePtr_save]
        str     x4, [sp, scoresPtr_save]
	
	// calculates B and W
        // findBW(setup, code, userGuess, score);			
	ldr	x2, [sp, userGuessPtr_save]
	ldr	x3, [sp, scoresPtr_save]
	bl	findBW
		
        // S- calculate cumulative score
        //double stepScore = (score->B + (score->W/ 2)) / score->numOfTrials;	
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_B_offset
	ldr	w1, [x0]
	scvtf   d0, w1				// int to float
		
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_W_offset
	ldr	w1, [x0]
	scvtf   d1, w1
	mov	w2, 2
	scvtf	d2, w2
	fdiv	d1, d1, d2			// (score->W/ 2)
	fadd	d0, d0, d1			// score->B + (score->W/ 2)
		
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_numOfTrials_offset
	ldr	w1, [x0]
	scvtf   d1, w1
	fdiv	d0, d0, d1			// stepScore = d0

	// calculates cmulative score
        //score->cumScore += stepScore;						
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_cumScore_offset
	ldr     d1, [x0]

	fadd	d0, d0, d1
	str	d0, [x0]

        //findTime(setup.maxTime * 60, gameTime);			
	ldr	x1, [sp, setupPtr_save]
	add	x1, x1, s_UserSetup_maxTime_offset
	ldr	w0, [x1]	
	mov	w3, 60				// to convert from min to sec
	mul	w0, w0, w3
	ldr     x1, [sp, gameTimePtr_save]
	bl	findTime
	
	// checks if time exceeded
        // if (gameTime->timeRemaining < 0)			
        //	gameTime->timeRemaining = 0;
	ldr     x1, [sp, gameTimePtr_save]
	add	x1, x1, s_GameTime_timeRemaining_offset
	ldr	x0, [x1]
	cmp	x0, 0
	b.ge	calculateScore_1
	
	mov	x0, 0
	str	x0, [x1]

calculateScore_1:
        // calculates final score
	//score->finalScore = (score->cumScore / score->numOfTrials) * gameTime->timeRemaining * 1000;	
		
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_cumScore_offset
	ldr	d0, [x0]

	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_numOfTrials_offset
	ldr	w1, [x0]
	scvtf   d1, w1
	fdiv	d0, d0, d1				// score->cumScore/ score->numOfTrials
		
	ldr     x1, [sp, gameTimePtr_save]
	add	x1, x1, s_GameTime_timeRemaining_offset
	ldr	x0, [x1]
	scvtf   d1, x0
	fmul	d0, d0, d1				// *gameTime->timeRemaining
		
	mov	x0, 1000
	scvtf   d1, x0
	fmul	d0, d0, d1				// *1000
		
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_finalScore_offset
	str	d0, [x0]				// update final score
	
	// checks for game over conditions
        // if (score->B == setup.rows*setup.columns || gameTime->timeRemaining <= 0 )
        //	return true;
	ldr	x1, [sp, setupPtr_save]
	add	x1, x1, s_UserSetup_rows_offset
	ldr	w0, [x1]	
		
	ldr	x1, [sp, setupPtr_save]
	add	x1, x1, s_UserSetup_columns_offset
	ldr	w1, [x1]
	mul	w19, w0, w1				// w19 = setup.rows*setup.columns
	
		
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_B_offset
	ldr	w1, [x0]
	cmp	w1, w19
	b.eq	calculateScore_true
		
	ldr     x1, [sp, gameTimePtr_save]
	add	x1, x1, s_GameTime_timeRemaining_offset
	ldr	x0, [x1]
	cmp	x0, 0
	b.le	calculateScore_true
	
	// checks for game over coniditions
        //if (score->numOfTrials >= setup.maxTrials)	
        //	score->finalScore = score->finalScore * -1;
        //	return true;
	ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_numOfTrials_offset
	ldr	w0, [x0]		

	ldr	x1, [sp, setupPtr_save]
	add	x1, x1, s_UserSetup_maxTrials_offset
	ldr	w1, [x1]	
		
	cmp	w0, w1
	b.lt	calculateScore_false

        ldr	x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_finalScore_offset
	ldr	d0, [x0]				// update final score
	mov	w1, -1
	scvtf	d1, w1
	fmul	d0, d0, d1
	str	d0, [x0]

calculateScore_true:
	mov 	w0, 1					// game done
	b	calculateScore_end
	
calculateScore_false:
	mov	w0, 0					// game not done

calculateScore_end:
	ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp x29, x30, [sp], dealloc

	ret

//* Description: Records player names and score in log file
//*
//* @param	setup		hold player information
//*		score 		holds all scores
//*		gameTime	holds game time information
// void logScore(struct UserSetup setup,
//                        struct GameTime gameTime
//			  struct AllScores score)

logScore:
        setupPtr_size = 8
	gameTimePtr_size = 8
        scoresPtr_size = 8
	tmpStr_size = 80
        x19_20_21_total_size = 24
        total_size = 48+80

        alloc = -(16 + total_size) & -16          // 0 size for testing only
        dealloc = -alloc

        setupPtr_save = 16
        gameTimePtr_save = 24
	scoresPtr_save = 32
	tmpStr_save = 40
        x19_save = 120
        x20_save = 128
        x21_save = 136

        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
		
	str     x0, [sp, setupPtr_save]
        str     x1, [sp, gameTimePtr_save]
        str     x2, [sp, scoresPtr_save]

	// FILE *fp;
	// fp = fopen("mastermind.log", "a+");		// creates/ adds to log file
	ldr	x0, =string_LogFilename
	ldr	x1, =string_Append
	bl	fopen
	mov	x19, x0

	// char timeStr[80];
	// timeToString(gameTime.timeRemaining, timeStr);
	ldr     x0, [sp, gameTimePtr_save]
	add 	x0, x0, s_GameTime_timeRemaining_offset
	ldr	x0, [x0]
	add	x1, sp, tmpStr_save
	bl	timeToString

	// if (score.finalScore == MY_NEG_INFINITY)
	//	  fprintf(fp,"%s -INFINITY INFINITY\n", setup.playerName);
	// else
	//    fprintf(fp,"%s %f %s\n", setup.playerName, score.finalScore, timeStr);	
	ldr     x0, [sp, scoresPtr_save]
	add	x0, x0, s_AllScores_finalScore_offset
	ldr	d0, [x0]
	mov	w1, MY_NEG_INFINITY
	scvtf	d1, w1 
	fcmp	d0, d1			// check for player quit
	b.ne	logScore_1
		
	mov	x0, x19			// player quit
	ldr	x1, =string_ShowInfinity
	ldr	x2, [sp, setupPtr_save]
	add	x2, x2, s_UserSetup_playerName_offset
	bl	fprintf		
logScore_1:
	mov	x0, x19			// not quit
	ldr	x1, =string_LogScores
	ldr	x2, [sp, setupPtr_save]
	add	x2, x2, s_UserSetup_playerName_offset
	ldr     x3, [sp, scoresPtr_save]
	add	x3, x3, s_AllScores_finalScore_offset
	ldr	d0, [x3]
	add	x3, sp, tmpStr_save
	bl	fprintf

	ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp 	x29, x30, [sp], dealloc

	ret

//* Description: records the game played in a txt file
//*
//* @param	setup		player information
//*		code		not used
//*		gameTime	used to build file name
// void transcripeGame(struct UserSetup setup,
//			char code[setup.rows][setup.columns],
//			struct GameTime gameTime)

transcripeGame:
        setupPtr_size = 8
        codePtr_size = 8
        gameTimePtr_size = 8
        now_size = 8
	timeStr_size = 128
        buf_size = 128
        x19_20_21_total_size = 24
        total_size = 48 + 256

        alloc = -(16 + total_size) & -16          // 0 size for testing only
        dealloc = -alloc

        setupPtr_save = 16
        codePtr_save = 24
        gameTimePtr_save = 32
	now_save = 40
        timeStr_save = 48
        buf_save = 176
        x19_save = 304
        x20_save = 312
        x21_save = 320

        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        str     x0, [sp, setupPtr_save]
        str     x1, [sp, codePtr_save]
        str     x2, [sp, gameTimePtr_save]


        // now = time(NULL);
        mov     x0, 0
        bl      time
	mov	x19, x0				// x19 = now...get current time
	add	x1, sp, now_save
	str	x19, [x1]	


        // ts = localtime(&now);                
	add	x0, sp, now_save
        bl      localtime
        mov     x20, x0                         // x20 = ts

        // strftime(buf, sizeof(buf), "%H-%M-%S", ts);
	add	x0, sp, buf_save
	mov	x1, 80
	ldr	x2, =string_TimeHMS
	mov	x3, x20						// x3 = ts
	bl	strftime

        // sprintf(timeStr, "%s_%s", setup.playerName, buf);
	add	x0, sp, timeStr_save
	ldr	x1, =string_NameWithTime
        ldr     x2, [sp, setupPtr_save]
        add     x2, x2, s_UserSetup_playerName_offset
	add	x3, sp, buf_save
	bl	sprintf

        // snprintf(buf, sizeof(testBuf), "%s.txt", timeStr);
	add	x0, sp, buf_save
	mov	x1, 80
	ldr	x2, =string_TimeFilename
	add	x3, sp, timeStr_save
	bl	snprintf

	// FILE *fp;
	// fp = fopen(buf, "a+");
	add	x0, sp, buf_save
	ldr	x1, =string_Append
	bl	fopen
	mov	x21, x0						// x21 = fp
		
	// for (int i = 0; i < startUpRow; i++)			// print start game messages
	// 	fprintf(fp, "%s", startUpOutput[i] );
	ldr	x0, =startUpRow
	ldr	w20, [x0]					// x20 = startUpRow
	mov	x19, 0						// x19 = i = 0
transcripeGame_1:
	mov	x0, 100						// startUpOutput's colunm size 100
	mul	x0, x0, x19
	ldr	x2, =startUpOutput
	add	x2, x2, x0					// startUpOutput[i]
	mov	x0, x21
	ldr	x1, =string_Input_String
	bl	fprintf
	add	w19, w19, 1
	cmp	w19, w20					// i < startUpRow
	b.lt	transcripeGame_1

	// for (int i = 0; i < screenCurrentRow; i++)		// print all hints for this game
	//	fprintf(fp, "%s", screenOutput[i] );
	ldr	x0, =screenCurrentRow
	ldr	w20, [x0]					// x20 = screenCurrentRow
	mov	w19, 0						// x19 = i = 0
transcripeGame_2:
	mov	x0, 80						// screenOutput's colunm size 80
	mul	x0, x0, x19
	ldr	x2, =screenOutput
	add	x2, x2, x0					// screenOutput[i]
	mov	x0, x21
	ldr	x1, =string_Input_String
	bl	fprintf
	add	w19, w19, 1
	cmp	w19, w20					// i < screenCurrentRow
	b.lt	transcripeGame_2
		
	// for (int i = 0; i < gameOverRow; i++)		// print game over messages
	//	fprintf(fp, "%s", gameOverOutput[i] );
	ldr	x0, =gameOverRow
	ldr	w20, [x0]					// x20 = gameOverRow
	mov	w19, 0						// x19 = i = 0
transcripeGame_3:
	mov	x0, 100						// gameOverOutput's colunm size 100
	mul	x0, x0, x19
	ldr	x2, =gameOverOutput
	add	x2, x2, x0					// gameOverOutput[i]
	mov	x0, x21
	ldr	x1, =string_Input_String
	bl	fprintf
	add	w19, w19, 1
	cmp	w19, w20					// i < gameOverRow
	b.lt	transcripeGame_3

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp x29, x30, [sp], dealloc

        ret

//* Description: exits the game
//*
//* @param	setup		passes user input parameters
//* 		score		passes final score information
//* 		gameTime	passes final time
// void exitGame( struct UserSetup setup,
//		  char code[setup.rows][setup.columns],
//		  struct GameTime gameTime,
//                struct AllScores scores)

exitGame:
        temp_stack_size = 128
	setupPtr_size = 8
	codePtr_size = 8
	gameTimePtr_size = 8
	scoresPtr_size = 8
	x19_20_21_22_total_size = 32
        total_size = 128 + 32 + 32

        alloc = -(16 + total_size) & -16          // 0 size for testing only
        dealloc = -alloc

        temp_stack_save = 16
        setupPtr_save = temp_stack_save + temp_stack_size
        codePtr_save = setupPtr_save + setupPtr_size
        gameTimePtr_save = codePtr_save + codePtr_size
        scoresPtr_save = gameTimePtr_save + gameTimePtr_size
	x19_save = scoresPtr_save + scoresPtr_size
        x20_save = x19_save + 8
        x21_save = x20_save + 8
        x22_save = x21_save + 8


        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]

	str	x0, [sp, setupPtr_save]
	str	x1, [sp, codePtr_save]
	str	x2, [sp, gameTimePtr_save]
	str	x3, [sp, scoresPtr_save]

	// logScore(setup, gameTime, score);
	                                        // copy mySetup to stack
	ldr	x2, [sp, setupPtr_save]		// source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x19, sp, temp_stack_save        // set x19 to copied data

                                                // copy myGameTime to stack
        ldr     x2, [sp, gameTimePtr_save]      // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x20, sp, temp_stack_save + s_UserSetup_total_size        // set x20 to copied data

                                                // copy myScores to stack
        ldr     x2, [sp, scoresPtr_save]         // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x21, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size       // set x20 to copied data

        mov     x0, x19
        mov     x1, x20
        mov     x2, x21
	bl	logScore

	// transcripeGame(setup, code, gameTime);	
                                                // copy mySetup to stack
        ldr     x2, [sp, setupPtr_save]         // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x19, sp, temp_stack_save        // set x19 to copied data

                                                // copy myGameTime to stack
        ldr     x2, [sp, gameTimePtr_save]      // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x20, sp, temp_stack_save + s_UserSetup_total_size        // set x20 to copied data

        mov     x0, x19
        ldr     x1, [sp, codePtr_save]
        mov     x2, x20
	bl	transcripeGame

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
	ldp x29, x30, [sp], dealloc
	ret

//* Description: user can also ask to display the top n scores before or after any game, including player names and duration.
//*
//* @param	numOfTop	number of top scores
// void displayTopBottom(bool showBottom, int numOfScores)

displayTopBottom:
	showBottom_size = 4			// integer
        numOfScores_size = 4			// integer
	fptr_size = 8				// pointer
	tmpName_size = 20			// char
        tmpScore_size = 80			// char
	tmpScoreFloat_size = 8			// float
        tmpDuration_size = 10			// char
        namePtr_size = 8			// char *
        scorePtr_size = 8			// double *
        durationPtr_size = 8			// char *
        x19_20_21_22_total_size = 32
        total_size = 16 + 110 + 24 + 32

        alloc = -(16 + total_size) & -16  
        dealloc = -alloc
		
	showBottom_save = 16
	numOfScores_save = 20
	fptr_save = 24
	tmpName_save = 32
        tmpScore_save = 52
	tmpScoreFloat_save = 132
        tmpDuration_save = 140
        namePtr_save = 150
        scorePtr_save = 158
        durationPtr_save = 166
        x19_save = 174
        x20_save = 182
        x21_save = 190
        x22_save = 198
		
        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x21 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]
		
	str	w0, [sp, showBottom_save]	//1 = show bottom, 0 = show top
	str	w1, [sp, numOfScores_save]

        //* initializes top scores arrays*/
        //for (int i = 0; i < numOfScores; i++)
        //    name[i][0] = 0;        
        //    score[i] = -INFINITY;
        //    duration[i][0] = 0;
	
	mov	w21, 0
	ldr	w21, [sp, numOfScores_save]	// w21 = numOfScores

	// allocate memory for namePtr_save, scorePtr_save, and durationPtr_save
	mov	x22, x21
	add	x22, x22, 1		// extra buffer for copying
	mov	x0, 20			// char name[numOfScores][20]
	mul	x0, x0, x22
	bl	malloc
	str	x0, [sp, namePtr_save]

        mov     x0, 8                  // double score[numOfScores]
        mul     x0, x0, x22
        bl	malloc
        str     x0, [sp, scorePtr_save]

        mov     x0, 10                  // name[numOfScores][10]
        mul     x0, x0, x22
        bl	malloc
        str     x0, [sp, durationPtr_save]

	mov     x19, 0
displayTop_loop1:
	mov	x0, 20			// name's column wide = 20
	mul	x0, x0, x19
	ldr	x1, [sp, namePtr_save]
	add	x1, x1, x0		// x1 = &name[i][0] 
	mov	x0, 0
	strb	w0, [x1]		// name[i][0] = 0
		
	mov	x0, 8			// double size
	mul	x0, x0, x19
	ldr	x1, [sp, scorePtr_save]
	add	x1, x1, x0		// x1 = &score[i]
	ldr	w2, [sp, showBottom_save]
	cmp	w2, 0
	b.eq	displayTop_showTop
//	mov     w0, MY_POS_INFINITY     // show bottom - TODO fix up the infinity num
	mov	w0, 0x7f800000
	b	displayTop_showCont
displayTop_showTop:
//	mov	w0, MY_NEG_INFINITY	// show top - TODO fix up the infinity num
	mov     w0, 0xff800000
displayTop_showCont:
	scvtf   d0, w0
	str	d0, [x1]		// score[i] = + or - INFINITY

	mov	x0, 10			// duration's column wide = 10
	mul	x0, x0, x19
	ldr	x1, [sp, durationPtr_save]
	add	x1, x1, x0		// x1 = &duration[i][0] 
	mov	x0, 0
	strb	w0, [x1]		// duration[i][0] = 0
		
	add	x19, x19, 1
	cmp	x19, x21
	b.lt	displayTop_loop1

	// fptr = fopen("mastermind.log","r");	// read log file
	// if (fptr == NULL)
	//    printf("Error! File is Empty.\n");
	//    return;
		
	ldr	x0, =string_LogFilename
	ldr	x1, =string_ReadOnly
	bl	fopen
	str	x0, [sp, fptr_save]
	cmp	x0, 0
	b.ne	displayTop_scan
		
	ldr	x0, =string_ErrorFileEmpty
	bl	printf
	b	displayTop_end
		
	//* scans file for top scores */
	//while (fscanf( fptr, "%s %s %s", tmpName, tmpScore, tmpDuration ) == 3 )
	//	 if (strcmp(tmpScore,"-INFINITY") != 0)
	//	    float logScore = atof(tmpScore);						
	//		for (int i = 0; i < numOfScores; i++)
	//		    if (logScore > score[i])                 				
	//			    for (int j = numOfScores - 1; j > (i - 1); j--)
	//				    score[j] = score[j-1];      				
	//				    strcpy(name[j], name[j-1]);
	//				    strcpy(duration[j], duration[j-1]);
	//		        score[i] = logScore;    				
	//		        strcpy(name[i], tmpName);
	//		        strcpy(duration[i], tmpDuration);
	//		        break;						
displayTop_scan:
	//while (fscanf( fptr, "%s %s %s", tmpName, tmpScore, tmpDuration ) == 3 )
	ldr	x0, [sp, fptr_save]
	ldr	x1, =string_Input_3Strings
	add	x2, sp, tmpName_save
	add	x3, sp, tmpScore_save
	add	x4, sp, tmpDuration_save
	bl	fscanf
	cmp	w0, 3
	b.ne	displayTop_leaveScan

// TODO - needs to be fixed with floating points
	//if (strcmp(tmpScore,"-INFINITY") != 0)
	add	x0, sp, tmpScore_save
	ldr	x1, =string_NegInfinity
	bl	strcmp
	cmp	x0, 0
	b.eq	displayTop_scan			// skip -infinity records
	
	//logScore = atof(tmpScore);	
	add	x0, sp, tmpScore_save		
	bl 	atof				// d0 = logScore...string to float
	
	add	x0, sp, tmpScoreFloat_save
	str	d0, [x0]
		
	//for (int i = 0; i < numOfScores; i++)
	mov	x19, 0				// x19 = i = 0
displayTop_loop_i:
	//check if (logScore > score[i]) or (logScore < score[i]) based on show top or bottom   
	mov	x0, 8			// double size
	mul	x0, x0, x19
	ldr	x22, [sp, scorePtr_save]
	add	x22, x22, x0		// x22 = &score[i]
	ldr	d1, [x22]		// d1 = score[i]

        ldr     w2, [sp, showBottom_save]
        cmp     w2, 0
        b.eq    displayTop_showTop1
       	// show bottom
        fcmp    d0, d1                  // if (logScore < score[i])
        b.ge    displayTop_loop_i_incr	// a larger value, skip to next one

        b       displayTop_showCont1
displayTop_showTop1:
        // show top 
        fcmp    d0, d1                  // if (logScore > score[i])
        b.le    displayTop_loop_i_incr	// a smaller value, skip to next one

displayTop_showCont1:

	//for (int j = numOfScores - 2, j > i; j--) 
	mov	x0, x21			// numOfScores
	sub	x0, x0, 2
	cmp	x0, x19
	b.lt	displayTop_updateBuffer
	mov	x20, x0			// x20 = j = numOfScores - 2
		
displayTop_loop_j:
	//score[j+1] = score[j];    // shift the top scores down by 1
		
	mov	x1, 8			// double size
	mov	x0, x20			// x0 = j
	mul	x0, x0, x1		// x0 = j*8
	ldr	x1, [sp, scorePtr_save]
	add	x1, x1, x0		// x1 = &score[j]
	ldr	d3, [x1]		// d3 = score[j]
		
	mov	x1, 8			// double size
	mov	x0, x20
	add	x0, x0, 1		;; x0 = j+1
	mul	x0, x0, x1		// x0 = (j+1)*8
	ldr	x1, [sp, scorePtr_save]
	add	x1, x1, x0		// x1 = &score[j]
	str	d3, [x1]		// score[j+1] = score[j]
		
	//strcpy(name[j+1], name[j]);
        mov     x1, 20                  // name's column wide = 20
        mov     x2, x20
        add     x2, x2, 1               // j+1
        mul     x2, x1, x2              // (j+1)*20
        ldr     x1, [sp, namePtr_save]
        add     x0, x1, x2              // x0 = &name[j+1][0]

	mov	x1, 20			// name's column wide = 20	
	mov	x2, x20
	mul	x2, x1, x2		// x0 = j*20
	ldr	x1, [sp, namePtr_save]
	add	x1, x1, x2		// x0 = &name[j][0] 

	bl	strcpy
		
	//strcpy(duration[j+1], duration[j]);
        mov     x1, 10                  // duration column wide = 10
        mov     x2, x20
        add     x2, x2, 1               // j+1
        mul     x2, x1, x2              // (j+1)*20
        ldr     x1, [sp, durationPtr_save]
        add     x0, x1, x2              // x0 = &name[j+1][0]

        mov     x1, 10                  // duration column wide = 10
        mov     x2, x20
        mul     x2, x1, x2              // x0 = j*20
        ldr     x1, [sp, durationPtr_save]
        add     x1, x1, x2              // x0 = &name[j][0]

	bl	strcpy

	sub	x20, x20, 1		// j--
	cmp	x20, x19		// j > i
	b.ge	displayTop_loop_j

displayTop_updateBuffer:	
	// score[i] = logScore; 
//TODO - check logScore value
        add     x0, sp, tmpScoreFloat_save
        ldr     d0, [x0]

        mov     x1, 8                   // double size
        mov     x0, x19                 // x0 = i
        mul     x0, x0, x1              // x0 = i*8
        ldr     x1, [sp, scorePtr_save]
        add     x1, x1, x0              // x1 = &score[i]
        str     d0, [x1]                // score[i] = d0...add the tmpScore to the right position
		
	// strcpy(name[i], tmpName);
	mov	x2, 20			// name's column wide = 20	
	mul	x2, x2, x19		// x2 = i*20
	ldr	x0, [sp, namePtr_save]
	add	x0, x0, x2		// x0 = &name[i][0] 
	add	x1, sp, tmpName_save
	bl	strcpy
		
	// strcpy(duration[i], tmpDuration);
	mov	x2, 10			// duration's column wide = 10	
	mul	x2, x2, x19		// x2 = i*10
	ldr	x0, [sp, durationPtr_save]
	add	x0, x0, x2		// x0 = &duration[i][0] 
	add	x1, sp, tmpDuration_save
	bl	strcpy
	b	displayTop_scan		// continue reading log file
		
displayTop_loop_i_incr:
	add	x19, x19, 1
	cmp	x19, x21		// if i < numOfScores
	b.lt	displayTop_loop_i

	b	displayTop_scan		// continue to read till end of file
		
// leaving displayTop_scan loop
displayTop_leaveScan:

	// for (int i = 0; i < numOfScores; i++)
	mov 	x19, 0			// x19 = i = 0
displayTop_loop2_i:
	// print top scores		
	// printf("%s %f %s\n", name[i], score[i], duration[i])

	ldr	x0, =string_Input_Str_Float_Str
		
	mov	x4, 20			// name's column wide = 20	
	mul	x4, x4, x19		// x4 = i*20
	ldr	x1, [sp, namePtr_save]
	add	x1, x1, x4		// x1 = &name[i][0] 		
		
	mov	x4, 8			// double size
	mul	x4, x4, x19		// x4 = i*8
	ldr	x2, [sp, scorePtr_save]
	add	x2, x2, x4		// x2 = &score[i] 			
	ldr	d0, [x2]		// d0 = score[i]
	
	mov	x4, 10			// duration's column wide = 10
	mul	x4, x4, x19		// x4 = i*8
	ldr	x2, [sp, durationPtr_save]
	add	x2, x2, x4		// xs = &score[i][0] 
		
	bl	printf

	add	x19, x19, 1
	cmp	x19, x21		// i < numOfScores
	b.lt	displayTop_loop2_i


displayTop_end:
       // allocate memory for namePtr_save, scorePtr_save, and durationPtr_save
	ldr	x0, [sp, namePtr_save]
	bl	free
	ldr	x0, [sp, scorePtr_save]
	bl	free
	ldr	x0, [sp, durationPtr_save]
	bl	free

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
	ldp     x29, x30, [sp], dealloc
        ret


// void displayBottom(int numOfBottom)
displayBottom:
// merged with top score	
	ret

//* Description: asks user for how many top or bottom scores
// bool checkDisplayTopBottom()
checkDisplayTopBottom:
        n_size = 4
        checkPlayAgainArray_size = 64
        x19_20_21_total_size = 24
        total_size = 92

        alloc = -(16 + total_size) & -16
        dealloc = -alloc

        n_save = 16
        checkPlayAgainArray_save = 20
        x19_save = 84
        x20_save = 92
        x21_save = 100

        stp     x29, x30, [sp, alloc]!  	// saves the state of the registers used by calling code
        mov     x29, sp                 	// updates FP to the current SP

        //save x19 - x21 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

checkDisplayTopBottom_repeat:
	// printf("Top Scores (0) or Bottom Scores (1)\n");
	ldr	x0, =string_TopBottomScore
	bl	printf
		
	// fgets(checkPlayAgain, 64, stdin);	// takes user input
        adrp    x0, stdin
        add     x0, x0, :lo12:stdin
        ldr     x2, [x0]
        add     x0, sp, checkPlayAgainArray_save
        mov     w1, 64
        bl      fgets

	// string1 = strtok(checkPlayAgain, " ");	// removes spaces from string
	add     x0, sp, checkPlayAgainArray_save
	ldr	x1, =string_Space
	bl	strtok
	mov	x19, x0					// x19 = string1 address

	// if (string1 != NULL)				// ensures string is not NULL
	//	 if (string1[0] == '$')			// checking for user quit
	//		  return true;
	//	 else
	//		TopOrBot = atoi(string1);
	//		/* top scores */
	//		if (TopOrBot == 0)
	//			printf("Enter number of Top Scores to display:\n");
	//			scanf("%d", &n);
	//			displayTop(n);

	//		/* bottom scores */
	//		else if (TopOrBot == 1)
	//			printf("Enter number of Bottom Scores to display:\n");
	//			scanf("%d", &n);
	//			displayBottom(n);
	//		return false;
	cmp	x19, 0
	b.eq	checkDisplayTopBottom_repeat
	
	ldrb	w0, [x19]				// if (string1[0] == '$')	
	cmp	w0, '$'					// check for user quit
	b.eq	checkDisplayTopBottom_true

	mov	x0, x19
	bl	atoi
	mov	w19, w0					// w19 = TopOrBot
	cmp	w19, 0					// check for top or bottom score '0' for top '1' for bot
	b.ne	checkDisplayTopBottom_bottom
		
	ldr	x0, =string_InputNumTopScores
	bl	printf
	ldr	x0, =string_Input_Integer
	add	x1, sp, n_save
	bl	scanf
	ldr	w1, [sp, n_save]
	mov	w0, 0					// display top scores
	bl	displayTopBottom

checkDisplayTopBottom_bottom:
	mov	w19, w0					// w19 = TopOrBot
	cmp	w19, 1
	b.ne	checkDisplayTopBottom_false

	ldr	x0, =string_InputNumBottomScores
	bl	printf
	ldr	x0, =string_Input_Integer
	add	x1, sp, n_save
	bl	scanf
	ldr	w1, [sp, n_save]
	mov	w0, 1					// display bottom scores
	bl	displayTopBottom
		
checkDisplayTopBottom_false:
	mov	x0, 0
	b	checkDisplayTopBottom_end
		
checkDisplayTopBottom_true:
	mov	x0, 1
	b	checkDisplayTopBottom_end

checkDisplayTopBottom_end:

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp 	x29, x30, [sp], dealloc

	ret


//* Description: checks user input for guess or quit
//*
//* @param	setup		user input parameters
//* 		userGuess	user inputed guess
//*
//* @return	true	quit command
//* 		false	user guess
// bool getGuessOrCommands(struct UserSetup setup,
//   			   char userGuess[setup.rows][setup.columns])

getGuessOrCommands:
        setupPtr_size = 8
        userGuessPtr_size = 8
	inputString_size = 128
	tmpString_size = 128
	x19_size = 8                            // allocate space to store register
	x20_size = 8
	x21_size = 8
	x22_size = 8
        total_size = 48 + 256 
        alloc = -(16 + total_size) & -16        // 0 size for testing only
        dealloc = -alloc
        setupPtr_save = 16                   	// sp offset
        userGuessPtr_save = setupPtr_save + setupPtr_size
        inputString_save = userGuessPtr_save + userGuessPtr_size
        tmpString_save = inputString_save + inputString_size
        x19_save = tmpString_save + 8
        x20_save = x19_save + 8
        x21_save = x20_save + 8
	x22_save = x21_save + 8
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
	str	x22, [sp, x22_save]

	str	x0, [sp, setupPtr_save]
	str	x1, [sp, userGuessPtr_save]

	add	x0, sp, inputString_save
	mov	x1, 0
	str	x1, [x0]

        add     x0, sp, tmpString_save
        mov     x1, 0
        str     x1, [x0]

getGuessOrCommands_getInput:
        adrp    x0, stdin               	    // putting address into a register
        add     x0, x0, :lo12:stdin         
        ldr     x2, [x0]			    // accessing variable
	add	x0, sp, inputString_save
	mov	w1, 100
	bl	fgets

        add     x0, sp, inputString_save
	ldr	x1, [x0]
	cmp	x1, 10		// continue to get input if only LF
	b.eq	getGuessOrCommands_getInput

	//for (int i = 0, j = 0; i<strlen(inputString); i++,j++)		
	//	if (inputString[i] != ' ')
	//		tmpString[j] = inputString[i];     					
	//	else
	//		 j--; 					
        mov     x19, 0          // x19 = i = 0
        mov     x20, 0          // x20 = j = 0
	add	x0, sp, inputString_save
	bl	strlen
	mov	x21, 0
	mov	w21, w0		// w21 = strlen(inputString)

getGuessOrCommands_copyString:
	cmp	x19, x21	// if i<strlen(inputString)
	b.ge	getGuessOrCommands_copyString_done
        add     x0, sp, inputString_save
	add	x0, x0, x19
	ldrb	w1, [x0]	// w1 = inputString[i]
	add	x19, x19, 1	// i++
	cmp	w1, 32		// check if ' '
	b.eq	getGuessOrCommands_copyString	

        add     x0, sp, tmpString_save
        add     x0, x0, x20
	strb	w1, [x0]	// tmpString[j] = inputString[i];	copy character to the output char[] if not space
	add	x20, x20, 1	// j++
	b	getGuessOrCommands_copyString

getGuessOrCommands_copyString_done:

	//* fill userGuess array */
	//for (int i = 0; i < setup.rows; i++)
	//	for (int j = 0; j < setup.columns; j++)
	//		userGuess[i][j] = tmpString[i*setup.columns + j];
        ldr     x0, [sp, setupPtr_save]
        add     x0, x0, s_UserSetup_rows_offset
        mov     x21, 0
        ldr     w21, [x0]                       // x21 = setup.rows

        ldr     x0, [sp, setupPtr_save]
        add     x0, x0, s_UserSetup_columns_offset
        mov     x22, 0
        ldr     w22, [x0]                       // x22 = setup.columns

	mov	x19, 0				// x19 = i = 0
getGuessOrCommands_fillString_i:
	mov 	x20, 0				// x20 = j = 0
getGuessOrCommands_fillString_j:
	mul	x0, x19, x22			// i*setup.columns
	add	x0, x0, x20			// i*setup.columns + j
	add     x1, sp, tmpString_save	
	add	x2, x1, x0			// &tmpString[i*setup.columns + j]
	ldrb	w3, [x2]			// w3 = tmpString[i*setup.columns + j]

        mul     x0, x19, x22    		// i*setup.columns
        add     x0, x0, x20     		// i*setup.columns + j
        ldr     x1, [sp, userGuessPtr_save]
	add     x2, x1, x0			// userGuess[i][j] = w3
        strb    w3, [x2]

	add	x20, x20, 1			// j++
	cmp	x20, x22
	b.lt	getGuessOrCommands_fillString_j

	add	x19, x19, 1			// i++
	cmp	x19, x21
	b.lt	getGuessOrCommands_fillString_i

	// startGame = false;
	// checkScore = false;
	mov	w0, 0
	ldr	x1, =startGame
	str	w0, [x1]

	ldr	x1, =checkScore
	str	w0, [x1]

	// if (userGuess[0][0] == '$') 	// user quit
	// 	return true
	ldr	x1, [sp, userGuessPtr_save]
	ldrb	w2, [x1]
	cmp	w2, '$'			// check user quit
	b.ne	getGuessOrCommands_startGame
	
	mov	w0, 1		// return true
	b	getGuessOrCommands_end

getGuessOrCommands_startGame:
	// if (userGuess[0][0] == '#')	// start game
	//	startGame = true
	//	return false
        ldr     x1, [sp, userGuessPtr_save]
        ldrb    w2, [x1]
 	cmp	w2, '#'			// check start game
	b.ne	getGuessOrCommands_scores
	
	mov	w3, 1
	ldr	x2, =startGame
	str	w3, [x2]	// startGame = true
	mov	w0, 0		// return false
	b	getGuessOrCommands_end

getGuessOrCommands_scores:
	// if (userGuess[0][0] == '!')	// scores
	//	checkScore = true
	//	return false
	// 
	// return false

	mov	w0, 0			// return false
        ldr     x1, [sp, userGuessPtr_save]
	ldrb	w2, [x1]
        cmp     w2, '!'			// check scores
        b.ne    getGuessOrCommands_end
	mov     w3, 1
        ldr     x2, =checkScore
        str     w3, [x2]        // checkScore = true

getGuessOrCommands_end:

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
        ldp     x29, x30, [sp], dealloc
        ret

//* Description: checks for start game, quit game and top/bottom score commands
//*
//* @param	setup		to check input
//* 		userGuess	to check input
// bool checkStartOrExitOrScore(struct UserSetup setup, 
//				char userGuess[setup.rows][setup.columns])

checkStartOrExitOrScore:
        setupPtr_size = 8
        userGuessPtr_size = 8
        x19_20_21_total_size = 24
        total_size = 40

        alloc = -(16 + total_size) & -16 
        dealloc = -alloc

        setupPtr_save = 16
        userGuessPtr_save = 24
        x19_save = 32
        x20_save = 40
        x21_save = 48

        stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]

        str     x0, [sp, setupPtr_save]
        str     x1, [sp, userGuessPtr_save]

	mov	w19, 0			// w19 = gameQuit

checkStartOrExitOrScore_loop:
	// printf("Start Game (#) or Quit Game ($) or Check Top/Bottom Scores (!)\n");
	ldr	x0, =string_DisplayCommands
	bl	printf

	// gameQuit = getGuessOrCommands(setup, userGuess);
        ldr     x0, [sp, setupPtr_save]
        ldr     x1, [sp, userGuessPtr_save]
	bl	getGuessOrCommands

	// if (gameQuit)
	//	return true
	mov	w19, w0
	cmp 	w19, 0
	b.ne	checkStartOrExitOrScore_true		// gameQuit = true, quitting

	// if (checkScore)
	//	gameQuit =checkDisplayTopBottom();
	//	if (gameQuit)
	//		return true
	//	checkScore = false

	ldr	x1, =checkScore
	ldr	w0, [x1]
	cmp	w0, 0
	b.eq	checkStartOrExitOrScore_checkStartGame

	// check score
	bl	checkDisplayTopBottom
	mov	w19, w0					// update x19 ie gameQuit
	cmp	w19, 0
	b.ne	checkStartOrExitOrScore_true		// gameQuit = true, quitting

	ldr     x1, =checkScore				// checkScore = false
        mov	w0, 0
	str     w0, [x1]

checkStartOrExitOrScore_checkStartGame:
	ldr	x1, =startGame
	ldr	w0, [x1]
	cmp	w0, 0
	b.eq	checkStartOrExitOrScore_loop		// not starting new game, repeat loop
	

checkStartOrExitOrScore_false:
	mov	w0, 0
	b	checkStartOrExitOrScore_end

checkStartOrExitOrScore_true:
	mov	w0, 1

checkStartOrExitOrScore_end:
        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldp x29, x30, [sp], dealloc
	ret

//* Description: user input validation
//*
//* @return true	if all input is valid
// bool checkUserSettings(struct UserSetup setup)

checkUserSettings:
        setupPtr_size = 8 
	inputStatus_size = 4
        x19_size = 8                            // allocate space to store register
	total_size = 20
        alloc = -(16 + total_size) & -16  
        dealloc = -alloc
        setupPtr_save = 16                       	// sp offset
        inputStatus_save = 24
	x19_save = 28
        stp     x29, x30, [sp , alloc]!
        mov     x29, sp

        str     x19, [sp, x19_save]
	mov	x19, x0				// base address of setup

	mov	w0, 1				// inputStatus = true
	strb	w0, [sp, inputStatus_size]
	 
	ldr	w0, [x19, s_UserSetup_rows_offset] 	// check if row < 1
	cmp	w0, 1
	b.ge	checkUserSettings_C
	ldr 	x0, =string_Input_Error_N
	bl	printf
	mov	w0, 0					// inputStatus = false
	strb    w0, [sp, inputStatus_size]
	
checkUserSettings_C:
	ldr     w0, [x19, s_UserSetup_columns_offset]      // check if column <= 4
        cmp     w0, 4
        b.gt    checkUserSettings_M
	mov	w0, 0
	strb	w0, [sp, inputStatus_size]
        ldr     x0, =string_Input_Error_C
        bl      printf

checkUserSettings_M:
        ldr     w0, [x19, s_UserSetup_columns_offset]      // check if column > numOfColours
	ldr     w1, [x19, s_UserSetup_numOfColours_offset]
        cmp     w0, w1
        b.lt    checkUserSettings_maxTrials
        mov     w0, 0
        strb    w0, [sp, inputStatus_size]
        ldr     x0, =string_Input_Error_M
        bl      printf

checkUserSettings_maxTrials:
        ldr     w0, [x19, s_UserSetup_maxTrials_offset]      // check if column <= 4
        cmp     w0, 1
        b.ge    checkUserSettings_maxTime
        mov     w0, 0
        strb    w0, [sp, inputStatus_size]
        ldr     x0, =string_Input_Error_R
        bl      printf

checkUserSettings_maxTime:
        ldr     w0, [x19, s_UserSetup_maxTime_offset]      // check if column <= 4
        cmp     w0, 0
        b.gt    checkUserSettings_end
        mov     w0, 0
        strb    w0, [sp, inputStatus_size]
        ldr     x0, =string_Input_Error_T
        bl      printf

checkUserSettings_end:
	ldrb 	w0, [sp, inputStatus_size]

        // restore registers, stack and return
        ldr     x19, [sp, x19_save]	
        ldp     x29, x30, [sp], dealloc
	ret

//* Description: Prompts user input, initializes, maintains, and terminates the game
//*
//* @param	argc argument count that holds the number of strings pointed
//*		*argv argument vector

main:
	temp_stack_size = 128		// for passing in structs

	mySetup_size = s_UserSetup_total_size
	myScores_size = s_AllScores_total_size
	myGameTime_size = s_GameTime_total_size
	struct_total_size = s_UserSetup_total_size + s_AllScores_total_size + s_GameTime_total_size

	userInputValid_size = 4
	modeSelect_size = 4
	codePtr_size = 8
	userGuessPtr_size = 8
	gameQuit_size = 4
	gameOver_size = 4
	locals_total_size = 32

        x19_20_21_22_total_size = 32

        total_size = temp_stack_size + struct_total_size + locals_total_size + x19_20_21_22_total_size

        alloc = -(16 + total_size) & -16    
        dealloc = -alloc

	temp_stack_save = 16
        mySetup_save = temp_stack_save + temp_stack_size
        myScores_save = mySetup_save + mySetup_size 
        myGameTime_save = myScores_save + myScores_size
	userInputValid_save = myGameTime_save + myGameTime_size
        modeSelect_save = userInputValid_save + userInputValid_size
        codePtr_save = modeSelect_save + modeSelect_size
        userGuessPtr_save = codePtr_save + codePtr_size
        gameQuit_save = userGuessPtr_save + userGuessPtr_size
        gameOver_save = gameQuit_save + gameQuit_size
	x19_save = gameOver_save + gameOver_size
        x20_save = x19_save + 8
        x21_save = x20_save + 8
	x22_save = x21_save + 8
        
	stp     x29, x30, [sp, alloc]!  // saves the state of the registers used by calling code
        mov     x29, sp                 // updates FP to the current SP

        //save x19 - x22 register
        str     x19, [sp, x19_save]
        str     x20, [sp, x20_save]
        str     x21, [sp, x21_save]
        str     x22, [sp, x22_save]

	// if (argc == 7)...validate number of arguments
        cmp     w0, 7                   // w0 argc - check if argv == 3
        b.eq     main_checkCommandLine

        // printf( "Input Error: " );
        ldr     x0, =string_Input_Error
        bl      printf

	b	main_getInputs

main_checkCommandLine:
        mov     x19, x1                 // save input arguments to x19

        // get player name
        ldr     x1, [x19, 8]            // 8 byte offset to account for the program name
        mov     x0, sp
        add     x0, x0, mySetup_save+s_UserSetup_playerName_offset	// struct offset
        bl      strcpy

        // get rows value
        ldr     x0, [x19, 16]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str	w0, [sp, mySetup_save+s_UserSetup_rows_offset]


        // get columns value
        ldr     x0, [x19, 24]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str     w0, [sp, mySetup_save+s_UserSetup_columns_offset]

        // get numOfColours value
        ldr     x0, [x19, 32]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str     w0, [sp, mySetup_save+s_UserSetup_numOfColours_offset]

        // get maxTrials value
        ldr     x0, [x19, 40]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str     w0, [sp, mySetup_save+s_UserSetup_maxTrials_offset]

        // get maxTime value
        ldr     x0, [x19, 48]            // 2nd argument N
        bl      atoi                    // converting string to integer
        str     w0, [sp, mySetup_save+s_UserSetup_maxTime_offset]

	b 	main_validateInputs

main_getInputs:
	// ask for new input if previous was invalid
	// printf( "Please enter Player Name, N, M, C, R, and T values\n" );
	//	scanf("%s %d %d %d %d %d",  mySetup.playerName,
	//				&mySetup.rows,
	//				&mySetup.columns,
	//				&mySetup.numOfColours,
	//				&mySetup.maxTrials,
	//				&mySetup.maxTime);

	ldr	x0, =string_Input_Message
	bl	printf

	ldr	x0, =string_Input_Scanf
	add	x1, sp, mySetup_save + s_UserSetup_playerName_offset 
	add     x2, sp, mySetup_save + s_UserSetup_rows_offset
	add     x3, sp, mySetup_save + s_UserSetup_columns_offset
	add     x4, sp, mySetup_save + s_UserSetup_numOfColours_offset
	add     x5, sp, mySetup_save + s_UserSetup_maxTrials_offset
	add     x6, sp, mySetup_save + s_UserSetup_maxTime_offset
	bl	scanf	

main_validateInputs:
	// userInputValid = checkUserSettings(mySetup);
	// copies mySetup_save on top of stack at temp_stack_save
	add	x2, sp, mySetup_save		// source address
	add	x3, sp, temp_stack_save		// destination address
	ldp	x0, x1, [x2]			// copy 16 bytes
	stp	x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                    // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                    // copy 16 bytes
        stp     x0, x1, [x3, 32]
	add	x0, sp, temp_stack_save		// set x0 to copied data
	bl      checkUserSettings		// check for valid input

	cmp	w0, 0
	b.eq	main_getInputs			// repeat until valid input received
	
main_requestGameMode:
	// request game mode from user
	// modeSelect = false
	mov	w0, 0			
	str	w0, [sp, modeSelect_save]

	// printf("Please select a mode: Play (0) or Test (1)\n");
	// scanf("%d", &mySetup.mode);
	ldr	x0, =string_Input_GameMode
	bl	printf

	ldr	x0, =string_Input_Integer
	add     x1, sp, mySetup_save + s_UserSetup_mode_offset
	bl	scanf

	// if (mySetup.mode == 1 || mySetup.mode == 0)
	//    modeSelect = true
	// else
	//    printf("Input Error: Please enter 1 or 0.\n");
	mov	w0, 0
	ldr	w0, [sp, mySetup_save + s_UserSetup_mode_offset]

	cmp	w0, 0
	b.eq	main_gameModeValid
	cmp	w0, 1
	b.eq	main_gameModeValid

	ldr	x0, =string_Input_GameMode_Error
	bl	printf

	b	main_requestGameMode

main_gameModeValid:
	// char (*code)[mySetup.columns] = malloc(mySetup.rows *mySetup. columns * sizeof(code[0][0]));
	mov	x0, 0
	mov	x1, 0
	ldr	w0, [sp, mySetup_save + s_UserSetup_rows_offset]
	ldr	w1, [sp, mySetup_save + s_UserSetup_columns_offset]
	mul	x0, x0, x1
	mov	x19, x0
	bl	malloc
	str	x0, [sp, codePtr_save]

	// char (*userGuess)[mySetup.columns] = malloc(mySetup.rows * mySetup.columns * sizeof(code[0][0]));
	mov	x0, x19
	bl	malloc
	str	x0, [sp, userGuessPtr_save]

	// gameQuit = checkStartOrExitOrScore(mySetup, userGuess);
						// copy mySetup to stack
        add     x2, sp, mySetup_save            // source address
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x0, sp, temp_stack_save         // set x0 to copied data
	ldr	x1, [sp, userGuessPtr_save]
	bl checkStartOrExitOrScore
	
	str	w0, [sp, gameQuit_save]

main_newGame:
	ldr	w0, [sp, gameQuit_save]
	cmp	w0, 0
	b.ne	main_quitGame			// run until game is quit
	
	// initializeGame (mySetup, code, &myGameTime, &myScores);
	                                        // copy mySetup to stack
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x0, sp, temp_stack_save        // set x0 to copied data
	
	ldr	x1, [sp, codePtr_save]
	add	x2, sp, myGameTime_save
	add     x3, sp, myScores_save
	bl 	initializeGame

	// gameOver = false;
	mov	w0, 0
	add	x1, sp, gameOver_save
	str	w0, [x1]

main_gameLoop: 
	// while (!gameOver && !gameQuit)..run until game is over
        ldr     w0, [sp, gameOver_save]
	cmp	w0, 0
	b.ne	main_gameOver

	
	ldr     w0, [sp, gameQuit_save]
        cmp     w0, 0
        b.ne    main_gameOver

	// Play game
	// myScores.numOfTrials++;... keep track of trials
	add	x0, sp, myScores_save+s_AllScores_numOfTrials_offset
	ldr	w1, [x0]
	add	w1, w1, 1
	str	w1, [x0]

	// printf( "Enter your guess below:\n");
	ldr     x0, =string_Input_EnterGuess
        bl      printf

        // gameQuit = getGuessOrCommands(mySetup,userGuess);
                                                // copy mySetup to stack
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x0, sp, temp_stack_save         // set x0 to copied data

	ldr	x1, [sp, userGuessPtr_save]
	bl	getGuessOrCommands

	str	w0, [sp, gameQuit_save]

	// if (gameQuit)
	//    myScores.finalScore = MY_NEG_INFINITY;
	//    myGameTime.timeRemaining = MY_POS_INFINITY;
	cmp	w0, 0
	b.eq 	main_showScoreHints
	
// TODO - use floating point for scores
	mov	w0, MY_NEG_INFINITY
	scvtf	d0, w0
	str	d0, [sp, myScores_save + s_AllScores_finalScore_offset]

	mov	x0, MY_POS_INFINITY
	str     x0, [sp, myGameTime_save + s_GameTime_timeRemaining_offset]

	b 	main_gameOver			// to log and transcripe game
main_showScoreHints:
	// gameOver = calculateScore(mySetup, code, userGuess, &myGameTime, &myScores);
                                                // copy mySetup to stack
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x0, sp, temp_stack_save         // set x0 to copied data

	ldr	x1, [sp, codePtr_save]
	ldr	x2, [sp, userGuessPtr_save]
	add	x3, sp, myGameTime_save
	add	x4, sp, myScores_save
	bl	calculateScore

	add     x1, sp, gameOver_save		
	str	w0, [x1]

	// displayHints(mySetup, userGuess, myGameTime, myScores);	
                                                // copy mySetup to stack
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x19, sp, temp_stack_save        // set x19 to copied data

                                                // copy myGameTime to stack
        add     x2, sp, myGameTime_save         // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x20, sp, temp_stack_save + s_UserSetup_total_size        // set x20 to copied data

                                                // copy myScores to stack
        add     x2, sp, myScores_save           // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x21, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size       // set x20 to copied data

        mov     x0, x19
	ldr	x1, [sp, userGuessPtr_save]
        mov     x2, x20
        mov     x3, x21
	bl	displayHints

	// if (gameOver)
	ldr	w0, [sp, gameOver_save]
	cmp	w0, 0
	b.eq	main_gameLoop			// game continues	

	//   if (myScores.B == mySetup.rows*mySetup.columns)	
	//	sprintf(gameOverOutput[gameOverRow++],"Cracked!\n");
	//	printf("Cracked!\n");
	ldr	w0, [sp, myScores_save + s_AllScores_B_offset]
	ldr	w1, [sp, mySetup_save + s_UserSetup_rows_offset]
	ldr	w2, [sp, mySetup_save + s_UserSetup_columns_offset]
	mul	w1, w1, w2
	cmp	w0, w1					// check for code cracked
	b.ne	main_numOfTrial
	
	ldr	x0, =gameOverOutput
	ldr	x1, =gameOverRow
	mov	x2, 0
	ldr	w2, [x1]
	mov	x3, 100			// column with 100
	mul	x2, x2, x3
	add	x0, x0, x2		// &gameOverOutput[gameOverRow]
	ldr	x1, =string_Cracked 		
	bl	sprintf

	ldr	x0, =string_Cracked
	bl	printf

	ldr     x1, =gameOverRow	// gameOverRow++
	ldr     w2, [x1]
	add     w2, w2, 1
	str     w2, [x1]

	b	main_finalScore

main_numOfTrial:	
	//   if (myScores.numOfTrials >= mySetup.maxTrials)
	// 	sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
	//	printf("Trials exceeded.\n");
        ldr     w0, [sp, myScores_save + s_AllScores_numOfTrials_offset]
        ldr     w1, [sp, mySetup_save + s_UserSetup_maxTrials_offset] 
        cmp     w0, w1			// check fo exceeded max trials
	b.lt	main_timeRemaining

        ldr     x0, =gameOverOutput
        ldr     x1, =gameOverRow
        mov     x2, 0
        ldr     w2, [x1]
        mov     x3, 100                 // column with 100
        mul     x2, x2, x3
        add     x0, x0, x2              // &gameOverOutput[gameOverRow]
        ldr     x1, =string_TrialsExceeded
        bl      sprintf

        ldr     x0, =string_TrialsExceeded
        bl      printf

        ldr     x1, =gameOverRow        // gameOverRow++
        ldr     w2, [x1]
        add     w2, w2, 1
        str     w2, [x1]

	b	main_finalScore

main_timeRemaining:
	//   if(myGameTime.timeRemaining <= 0)
	//	sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
	//	printf("Time exceeded.\n");
        ldr     w0, [sp, myGameTime_save + s_GameTime_timeRemaining_offset]
        cmp     w0, 0			// check for exceeded time
        b.gt    main_finalScore

        ldr     x0, =gameOverOutput
        ldr     x1, =gameOverRow
        mov     x2, 0
        ldr     w2, [x1]
        mov     x3, 100                 // column with 100
        mul     x2, x2, x3
        add     x0, x0, x2              // &gameOverOutput[gameOverRow]
        ldr     x1, =string_TimeExceeded
        bl      sprintf

        ldr     x0, =string_TimeExceeded
        bl      printf

        ldr     x1, =gameOverRow        // gameOverRow++
        ldr     w2, [x1]
        add     w2, w2, 1
        str     w2, [x1]

main_finalScore:
	//   sprintf(gameOverOutput[gameOverRow++],"Final Score: %.2f\n", myScores.finalScore);
	//   printf("Final Score: %.2f\n", myScores.finalScore);
        ldr     x0, =gameOverOutput
        ldr     x1, =gameOverRow
        mov     x2, 0
        ldr     w2, [x1]
        mov     x3, 100                 // column with 100
        mul     x2, x2, x3
        add     x0, x0, x2              // &gameOverOutput[gameOverRow]
        ldr     x1, =string_FinalScore
	ldr	d0, [sp, myScores_save + s_AllScores_finalScore_offset]
        bl      sprintf

	ldr     x0, =string_FinalScore
        ldr     d0, [sp, myScores_save + s_AllScores_finalScore_offset]
        bl      printf

        ldr     x1, =gameOverRow        // gameOverRow++
        ldr     w2, [x1]
        add     w2, w2, 1
        str     w2, [x1]

	//   gameQuit = checkStartOrExitOrScore(mySetup, userGuess);
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x0, sp, temp_stack_save        // set x0 to copied data

	ldr	x1, [sp, userGuessPtr_save]
	bl	checkStartOrExitOrScore

	str	w0, [sp, gameQuit_save]
main_gameOver:
	// exitGame(mySetup, code, myGameTime, myScores);
                                                // copy mySetup to stack
        add     x2, sp, mySetup_save            // source address; 48 bytes
        add     x3, sp, temp_stack_save         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        ldp     x0, x1, [x2, 32]                // copy 16 bytes
        stp     x0, x1, [x3, 32]
        add     x19, sp, temp_stack_save        // set x19 to copied data

                                                // copy myGameTime to stack
        add     x2, sp, myGameTime_save         // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x20, sp, temp_stack_save + s_UserSetup_total_size        // set x20 to copied data

                                                // copy myScores to stack
        add     x2, sp, myScores_save           // source address; 28 bytes
        add     x3, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size         // destination address
        ldp     x0, x1, [x2]                    // copy 16 bytes
        stp     x0, x1, [x3]
        ldp     x0, x1, [x2, 16]                // copy 16 bytes
        stp     x0, x1, [x3, 16]
        add     x21, sp, temp_stack_save + s_UserSetup_total_size + s_GameTime_total_size       // set x20 to copied data

        mov     x0, x19
	ldr	x1, [sp, codePtr_save]
        mov     x2, x20
        mov     x3, x21
// TODO uncomment
 	bl	exitGame

        ldr     w0, [sp, gameQuit_save]
        cmp     w0, 0
        b.ne    main_quitGame			// user quit game

	b 	main_newGame			// start a new game

main_quitGame:
main_end:
	ldr     x0, [sp, codePtr_save]
        bl      free          
	
	ldr     x0, [sp, userGuessPtr_save]
        bl      free          	

        ldr     x19, [sp, x19_save]
        ldr     x20, [sp, x20_save]
        ldr     x21, [sp, x21_save]
        ldr     x22, [sp, x22_save]
	ldp x29, x30, [sp], dealloc
	ret
