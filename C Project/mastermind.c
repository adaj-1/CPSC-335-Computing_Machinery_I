/*
 * mastermind.c
 *
 *  Created on: Jun. 1, 2021
 *      Author: jadal
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <stdbool.h>
#include <ctype.h>
#include <unistd.h>
#include <math.h>

#define MY_POS_INFINITY 999999
#define MY_NEG_INFINITY -999999

char startUpOutput[100][100];				// buffer to  hold game start up outputs
int startUpRow = 0;							// counts rows for buffer
char screenOutput[40][80];					// buffer to  hold in game screen outputs
int screenCurrentRow=0;						// counts rows for buffer
char gameOverOutput[100][100];				// buffer to  hold end game outputs
int gameOverRow = 0;						// counts rows for buffer

/*
 * Description: struct to hold all user input parameters
 */
struct UserSetup
{
	char playerName[20];					// command line input player name
	int rows;
	int	columns;
	int	numOfColours;
	int	maxTrials;
	int	maxTime;
	int	mode;
};

/*
 * Description: struct to hold all time variables for game
 */
struct GameTime
{
	time_t startTime;
	double timeRemaining;
	int hours;
	int minutes;
	int seconds;
};

/*
 * Description: struct to hold all scores for game
 */
struct AllScores
{
	int B;
	int W;
	int numOfTrials;
	double cumScore;
	double finalScore;
};

/*
 * Description: Random number generator
 *
 * @param	lowerBound 	for the random number generator
 * 			upperBound 	for the random number generator
 * 			neg			did not do as Prof said this was unnecessary in lecture
 * @return random integer within the bounds
 */
int randomNum (int lowerBound, int upperBound)
{
	return (rand() % (upperBound + 1 - lowerBound) + lowerBound);	// returns a random number within lower & upper bounds
}

/*
 * Description:  returns a letter (colour) based on an integer value n
 *
 * @param 	n			to randomize colour select
 *
 * @return	newColour	randomized colour
 */
char colour(int n)
{
	char newColour = (char) n + 'A';		// convert # to A-Z ASCII to represent color

	return newColour;
}

/*
 * Description: to determine time elapsed
 *
 * @param	maxTimeSec	time specified by user in seconds
 * 			gameTime	struct to store changes to time
 *
 */
void findTime(int maxTimeSec, struct GameTime *gameTime)
{
	time_t currentTime;
	time(&currentTime);												// gets current time

	time_t temp = difftime(currentTime, gameTime->startTime);		// calculates time difference

	gameTime->timeRemaining = maxTimeSec - temp;					// calculates time remaining

}

/*
 * Description: converts timeRemaining into a mm:ss format to be used for log and transcripe functions
 *
 * @param	timeInSec	timeRemaining in seconds
 * 			timeStr		formatted time in string
 */
void timeToString(double timeInSec, char *timeStr)
{
	if (timeInSec == MY_POS_INFINITY)		// TODO fix infinity
	{
		strcpy(timeStr, "INFINITY");
	}
	else if (timeInSec > 0)					// if maxTime is not exceeded
	{
		int minutes = 0;
		int seconds = 0;

		minutes = timeInSec / 60;
		seconds = timeInSec- (minutes * 60);

		sprintf(timeStr, "%02d:%02d", minutes, seconds); // string together minutes and seconds
	}
	else
	{
		strcpy(timeStr, "00:00");		// set time to 00:00 TODO do i need this?
	}
}

/*
 * Description: initializes code, time, scores, and mode
 *
 * @param	setup		prints starting messages and used to initialize code
 * 			code		creates randomized code
 * 			*gameTime	resets gameTime if game is restarted
 * 			*scores		resets scores if game is restarted
 */
void initializeGame (struct UserSetup setup,
					 char code[setup.rows][setup.columns],
					 struct GameTime *gameTime,
					 struct AllScores *scores)
{
	time(&gameTime->startTime);				// time stamps start of game

	/* initializing struct gameTime */
	gameTime->timeRemaining = 0;
	gameTime->hours = 0;
	gameTime->minutes = 0;
	gameTime->seconds = 0;

	/* initializing struct scores */
	scores->B = 0;
	scores->W = 0;
	scores->numOfTrials = 0;
	scores->cumScore = 0;
	scores->finalScore = 0;

	/* generating random seed for game*/
	time_t t;
	srand( (unsigned) time(&t) );

	/* resets display buffers */
	screenCurrentRow = 1;
	startUpRow = 0;
	gameOverRow = 0;

	if (setup.mode == 1)
	{
		sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
		printf("Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
	}
	else
	{
		sprintf(startUpOutput[startUpRow++], "Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
		printf("Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
	}

	/* generates randomized colour code and fills code array */
	for (int i = 0; i < setup.rows; i++ )
	{
		for (int j = 0; j < setup.columns; j++)
		{
			int randNum = randomNum( 0, setup.numOfColours - 1);	// upper/lower bound based on user input
			code[i][j] = colour(randNum);							// filling code with randomized colours
		}
	}

	if (setup.mode == 1)
	{
		sprintf(startUpOutput[startUpRow++],"Hidden code is: ");	// for transcripe game
		printf("Hidden code is: ");

		/* displays hidden code for test mode */
			for (int i = 0; i < setup.rows; i++ )
			{
				for (int j = 0; j < setup.columns; j++)
				{
					sprintf(startUpOutput[startUpRow++]," %c ", code[i][j]);
					printf(" %c ", code[i][j]);
				}
				sprintf(startUpOutput[startUpRow++],"\n");
				printf("\n");
			}
		}

	sprintf(startUpOutput[startUpRow++],"Start cracking...\n");
	printf("Start cracking...\n");

	/* prints initial user interface */
	for (int i = 0; i < setup.rows; i++ )
	{
		for (int j = 0; j < setup.columns; j++)
		{
			printf("- ");
		}

		if(i == 0)
		{
			printf("  B   W   R   S   T\n");
		}

		printf("\n");
	}
}

/*
 * Description: prints the hints
 *
 * @param	B is the num of colours that are correct and in the right slot
 * 			W is  the num of colours that are correct but in the wrong slot
 * 			R is the num of trials
 * 			S is the cumulative score
 * 			T is the remaining time
 */
void displayHints(struct UserSetup setup, struct GameTime gameTime, struct AllScores score, char userGuess[setup.rows][setup.columns])
{
	char userInputSpaceStr[80];								// to hold cracked code dashes
	char userInputStr[80];									// to hold userGuess

	userInputSpaceStr[0] = '\0';							// initialize to null
	userInputStr[0] = '\0';									// initialize to null


	/* to reprint user guess with hints */
	for (int i=0; i < setup.rows*setup.columns; i++)
	{
		strcat( userInputSpaceStr, "- ");
		userInputStr[2*i] = userGuess[0][i];
		userInputStr[2*i+1] = ' ';
		userInputStr[2*i+2] = '\0';
	}

	/* convert time in sec to mm:ss format  */
	char timeStr[20];
	timeToString(gameTime.timeRemaining, timeStr);

	/* generate screenOuput for the last results */
	sprintf(screenOutput[0], "%s  B  W  R  S    T\n", userInputSpaceStr);
	sprintf(screenOutput[screenCurrentRow++], "%s %2d %2d %2d  %4.2f %s\n", userInputStr,
																			score.B,
																		 score.W,
																		 score.numOfTrials,
																		 score.cumScore,
																		 timeStr);

	//system("clear");   //TODO uncomment

	for (int i = 0; i < screenCurrentRow; i++)		// print all hints for this game
	{
		printf( "%s", screenOutput[i] );
	}
}

/*
 * Description: finding B and W scores
 *
 * @param	setup		provides user input parameters
 * 			code		holds code
 * 			userGuess	holds user guess
 * 			*score		updates score
 */
void findBW(struct UserSetup setup,
			char code[setup.rows][setup.columns],
			char userGuess[setup.rows][setup.columns],
			struct AllScores *score)
{
	char tmpCode[setup.rows][setup.columns];				// tmp code to prevent override of code
	char tmpUserGuess[setup.rows][setup.columns];			// tmp userInput to prevent override of userGuess

	score->B = 0;
	score->W = 0;

	for (int i = 0; i < setup.rows; i++)
	{
		for (int j = 0; j < setup.columns; j++)
		{
			tmpCode[i][j] = code[i][j];
		}
	}

	for (int i = 0; i < setup.rows; i++)
	{
		for (int j = 0; j < setup.columns; j++)
		{
			tmpUserGuess[i][j] = userGuess[i][j];
		}
	}

	for (int i = 0; i < setup.rows; i++)
		{
			for (int j = 0; j < setup.columns; j++)
			{
				if (tmpUserGuess[i][j] == tmpCode[i][j])
				{
					score->B++;
					tmpUserGuess[i][j] = '0';						// set to 0 to avoid future match
					tmpCode[i][j] = '1';							// set to 1 to avoid future match
				}
			}
		}

	for (int i = 0; i < setup.rows; i++)
	{
		for (int j = 0; j < setup.columns; j++)
		{
			char colour = tmpUserGuess[i][j];

			for (int x = 0; x < setup.rows; x++)
			{
				for (int y = 0; y < setup.columns; y++)
				{
					if (colour == tmpCode[x][y])
					{
						score->W++;
						tmpUserGuess[i][j] = '0';
						tmpCode[x][y] = '1';
					}
				}
			}
		}
	}
}

/*
 * Description: returns overall score
 */
bool calculateScore(struct UserSetup setup,
					char code[setup.rows][setup.columns],
					char userGuess[setup.rows][setup.columns],
					struct GameTime *gameTime,
					struct AllScores *score)
{
	findBW(setup, code, userGuess, score);

	// S- calculate cumulative score
	double stepScore = (score->B + (score->W/ 2)) / score->numOfTrials;			// calculate stepscore

	score->cumScore += stepScore;

	findTime(setup.maxTime * 60, gameTime);										// *60 to convert from min to sec

	score->finalScore = (score->cumScore/ score->numOfTrials) * gameTime->timeRemaining * 1000;


	if (score->B == setup.rows*setup.columns)
	{
		//sprintf(gameOverOutput[gameOverRow++],"Cracked!\n");
		//printf("Cracked!\n");
		return true;
	}

	if (score->numOfTrials > setup.maxTrials- 1)
	{
		score->finalScore = score->finalScore * -1;
		//sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
		//printf("Trials exceeded.\n");
		return true;
	}

	if(gameTime->timeRemaining < 0)
	{
		//sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
		//printf("Time exceeded.\n");
		return true;
	}
	return false;
}

/*
 * Description: Records player names and score in log file
 *
 * @param	*playerName holds the userInput player name
 * 			score holds the current score
 * 			time holds how long the game was
 */
void logScore(struct UserSetup setup, struct AllScores score, struct GameTime gameTime)
{
	/* add in time */
	/* TODO users who do not finish the game are not included in the returned list */

	FILE *fp;
	fp = fopen("mastermind.log", "a+");											// creates/ adds to log file
	fprintf(fp,"%s %f %d:%d\n", setup.playerName,
								score.finalScore,
								gameTime.minutes,
								gameTime.seconds);			// records player name and score in log file
}

/*
 * Description:addition, a transcript file is created that
 *  records the game played (the steps in each move as shown on the screen
 */
void transcripeGame(struct UserSetup setup,
					char code[setup.rows][setup.columns],struct GameTime gameTime)
{
	//TODO didnt use *code as specified in assignment

	char timeStr[40];

	//CITATION: https://en.wikibooks.org/wiki/C_Programming/time.h/time_t
	time_t     now;
	    struct tm *ts;
	    char  testBuf[80];

	  /* Get the current time */
	  now = time(NULL);

	ts = localtime(&now);

	strftime(testBuf, sizeof(testBuf), "%H-%M-%S", ts);
	puts(testBuf);

	sprintf(timeStr, "%s_%s", setup.playerName, testBuf);

	char buf[0x100];
	snprintf(buf, sizeof(buf), "%s.txt", timeStr);

	FILE *fp;
	fp = fopen(buf, "a+");
	for (int i = 0; i < startUpRow; i++)		// print all hints for this game
	{
		fprintf(fp, "%s", startUpOutput[i] );
	}

	for (int i = 0; i < screenCurrentRow; i++)		// print all hints for this game
	{
		fprintf(fp, "%s", screenOutput[i] );
	}

	for (int i = 0; i < gameOverRow; i++)		// print all hints for this game
		{
			fprintf(fp, "%s", gameOverOutput[i] );
		}


}

void exitGame(struct UserSetup setup,
		char code[setup.rows][setup.columns],
		struct AllScores score,
		struct GameTime gameTime)
{
	logScore(setup, score, gameTime);
	transcripeGame(setup, code, gameTime);
}

bool checkUserQuit()
{
	char checkPlayAgain[50];
	char *string1;

	while (1)
	{
		printf("Play Again (0) or Exit ($)\n");
		fgets(checkPlayAgain, 50, stdin);																	// takes user input

		/* Citation: https://www.geeksforgeeks.org/strtok-strtok_r-functions-c-examples/ */
		string1 = strtok(checkPlayAgain, " ");																// removes spaces from string

		if (string1 != NULL)																			// ensures string is not NULL
		{
			if (string1[0] == '$')													// checking for user quit
			{
				return true;
			}
			else if (string1[0] == '0')															// getting row number
			{
				return false;
			}
		}
	}
}

/*
 * Description: user can also ask to display the top or bottom n scores
 *  before or after any game, including player names and duration.
 */
void displayTop(int numOfTop)
{
		FILE *fptr;

		char tmpName[20];
		float tmpScore;
		char tmpDuration[10];

		char name[numOfTop][20];     // highest score in slot 0
		double score[numOfTop];
		char duration[numOfTop][10];

		for (int i = 0; i < numOfTop; i++)
		{
			name[i][0] = 0;         // null string
		    score[i] = -INFINITY; // TODO set to -infinite
		    duration[i][0] = 0;
		}

		fptr = fopen("mastermind.log","r");

	    if (fptr == NULL)
		{
			printf("Error!\n");
			return;
		}

		while (fscanf( fptr, "%s %f %s", tmpName, &tmpScore, tmpDuration ) == 3 )
		{
			for (int i = 0; i < numOfTop; i++)
			{
				if (tmpScore > score[i])                  // add tmpScore to right position
		        {
					for (int j = numOfTop - 1; j > (i - 1); j--)
					{
						score[j] = score[j-1];       // shift the top scores down by 1
						strcpy(name[j], name[j-1]);
						strcpy(duration[j], duration[j-1]);
					}

					score[i] = tmpScore;    // add the tmpScore to the right position
					strcpy(name[i], tmpName);
					strcpy(duration[i], tmpDuration);
					break;					// break out of for loop
		        }
			}
		}

	    for (int i = 0; i < numOfTop; i++)
	    {
	    	 printf("%s %f %s\n", name[i], score[i], duration[i]);
	    }

}

void displayBottom(int numOfBottom)
{
		FILE *fptr;

		char tmpName[20];
		float tmpScore;
		char tmpDuration[10];

		char name[numOfBottom][20];     // highest score in slot 0
		double score[numOfBottom];
		char duration[numOfBottom][10];

		for (int i = 0; i < numOfBottom; i++)
		{
			name[i][0] = 0;         // null string
		    score[i] = MY_POS_INFINITY; // TODO set to infinite
		    duration[i][0] = 0;
		}

		fptr = fopen("mastermind.log","r");

		if (fptr == NULL)
		{
			printf("Error!\n");
			return;
		}

		while (fscanf( fptr, "%s %f %s", tmpName, &tmpScore, tmpDuration ) == 3 )
		{
			for (int i = 0; i < numOfBottom; i++)
			{
				if (tmpScore == MY_NEG_INFINITY)
				{
					printf("----> MY_NEG_INFINITY\n");
				}
				else
				{
					printf("----> not MY_NEG_INFINITY\n");
				}

				if (tmpScore < score[i] && tmpScore != MY_NEG_INFINITY)                  // add tmpScore to right position
		        {
					for (int j = numOfBottom - 1; j > (i - 1); j--)
					{
						score[j] = score[j-1];       // shift the top scores down by 1
						strcpy(name[j], name[j-1]);
						strcpy(duration[j], duration[j-1]);
					}
						score[i] = tmpScore;    // add the tmpScore to the right position
					strcpy(name[i], tmpName);
					strcpy(duration[i], tmpDuration);
					break;					// break out of for loop
		        }
			}
		}

		for (int i = 0; i < numOfBottom; i++)
		{
		   	 printf("%s %f %s\n", name[i], score[i], duration[i]);
		}
			//TODO infinity
}

void checkDisplayTopBottom()
{
	int option;
	int n;

	printf("Top Scores (0) or Bottom Scores (1) or Start Game (2)\n");
	scanf("%d", &option);

	if (option == 0)
	{
		printf("Enter number of Top Scores to display:\n");
		scanf("%d", &n);
		displayTop(n);
	}
	else if (option == 1)
	{
		printf("Enter number of Bottom Scores to display:\n");
		scanf("%d", &n);
		displayBottom(n);
	}
	return;
}

bool getGuessOrCommands(struct UserSetup setup,
								 char userGuess[setup.rows][setup.columns],
								 int *n)
{
	char inputString[100]= {0};
	char tmpString[100] = {0};

	do
	{
		fgets(inputString, 100, stdin);
	}
	while (inputString[0] == '\n');								// ignore NULL input

// CITATION: https://stackoverflow.com/questions/13084236/function-to-remove-spaces-from-string-char-array-in-c
	for (int i = 0, j = 0; i<strlen(inputString); i++,j++)		// Evaluate each character in the input
	{
		if (inputString[i] != ' ')
		{
			tmpString[j] = inputString[i];     	// If the character is not a space
		}	                                   	// Copy that character to the output char[]
		else
		{
			 j--;
		}		                               	// If it is a space then do not increment the output index (j), the next non-space will be entered at the current index
	 }
//TODO input validation that inputstring contains enough guesses
//TODO ensure there are enough characters entered and within the color range

	for (int i = 0; i < setup.rows; i++)
	{
		for (int j = 0; j < setup.columns; j++)
		{
			userGuess[i][j] = tmpString[i*setup.columns + j];
		}
	}

	printf("----> %c %c %c %c %c\n", userGuess[0][0],userGuess[0][1],userGuess[0][2],userGuess[0][3],userGuess[0][4]);

	if (userGuess[0][0] == '$')
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool checkUserSettings(struct UserSetup setup)
{
	bool inputStatus = true;

	if (setup.rows < 1)
	{
		printf("Input Error: N must be greater than or equal to 1.\n");
		inputStatus = false;
	}

	if (setup.columns <= 4)
	{
		printf("Input Error: C must be greater than or equal to 5.\n");
		inputStatus = false;
	}

	if (setup.columns > setup.numOfColours)
	{
		printf("Input Error: M must be greater than or equal to C.\n");
		inputStatus = false;
	}

	if (setup.maxTrials < 1)
	{
		printf("Input Error: R must be greater than or equal to 1.\n");
		inputStatus = false;
	}

	if (setup.maxTime <= 0)
	{
		printf("Input Error: T must be greater than 0 minutes.\n");
		inputStatus = false;
	}

	return inputStatus;
}

/*
 * Description: Prompts user input, initializes, maintains, and terminates the game
 *
 * @param	argc argument count that holds the number of strings pointed
 * 			*argv argument vector
 *
 */
int main(int argc, char *argv[])
{
	struct UserSetup mySetup;
	struct AllScores myScores;
	struct GameTime myGameTime;

	bool userInputValid = false;

	if (argc == 7)														// validate number of arguments
	{
		strcpy(mySetup.playerName, argv[1]);											// copying program argument to playerName
		mySetup.rows = atoi(argv[2]);														// converting string argument to integer
		mySetup.columns = atoi(argv[3]);
		mySetup.numOfColours = atoi(argv[4]);
		mySetup.maxTrials = atoi(argv[5]);
		mySetup.maxTime = atoi(argv[6]);

		userInputValid = checkUserSettings(mySetup);
	}
	else
	{
		printf( "Input Error: " );
	}

	while (!userInputValid)
	{
		printf( "Please enter Player Name, N, M, C, R, and T values\n" );
		scanf("%s %d %d %d %d %d",  mySetup.playerName,
									&mySetup.rows,
									&mySetup.columns,
									&mySetup.numOfColours,
									&mySetup.maxTrials,
									&mySetup.maxTime);

//TODO validate user input parameters

		userInputValid = checkUserSettings(mySetup);

		if (!userInputValid)
		{
			printf( "Input Error: " );
		}
	}

	bool modeSelect = false;
	do
	{
		printf("Please select a mode: Play (0) or Test (1)\n");
		scanf("%d", &mySetup.mode);


//TODO mode input validation check for non integers

		if (mySetup.mode == 1 || mySetup.mode == 0)
		{
			modeSelect = true;
		}
		else
		{
			printf("Input Error: Please enter 1 or 0.\n");
		}
	}
	while(!modeSelect);

	char (*code)[mySetup.columns] = malloc(mySetup.rows *mySetup. columns * sizeof(code[0][0]));	// allocate memory for code
	char (*userGuess)[mySetup.columns] = malloc(mySetup.rows * mySetup.columns * sizeof(code[0][0]));	// allocate memory for code

	int n = 0;									// initialize
	//TODO uncomment and add top bottom score

	//printf( "TOP BOTTOM SCORE:\n");				//TODO ask user for top/bottom score ONLY
	//getGuessOrCommands(mySetup,userGuess, &n);

	checkDisplayTopBottom();

	bool gameQuit = false;
	while (!gameQuit)
	{
		initializeGame (mySetup, code, &myGameTime, &myScores);
		bool gameOver = false;

		while (!gameOver && !gameQuit)
		{
			myScores.numOfTrials++;

			printf( "Enter your guess below:\n");
			gameQuit = getGuessOrCommands(mySetup,userGuess, &n);

			if (gameQuit)
			{
				myScores.finalScore = MY_NEG_INFINITY;
				myGameTime.minutes = 99;
				myGameTime.seconds = 99;			//TODO fix to positive infinity

			}
			else
			{
				gameOver = calculateScore(mySetup, code, userGuess, &myGameTime, &myScores);
				displayHints(mySetup, myGameTime, myScores, userGuess);
				if (gameOver)
				{
					if (myScores.B == mySetup.rows*mySetup.columns)
						{
							sprintf(gameOverOutput[gameOverRow++],"Cracked!\n");
							printf("Cracked!\n");

						}

						if (myScores.numOfTrials > mySetup.maxTrials- 1)
						{

							sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
							printf("Trials exceeded.\n");

						}

						if(myGameTime.timeRemaining < 0)
						{
							sprintf(gameOverOutput[gameOverRow++],"Trials exceeded.\n");
							printf("Time exceeded.\n");

						}

					sprintf(gameOverOutput[gameOverRow++],"Final Score: %.2f\n", myScores.finalScore);
					printf("Final Score: %.2f\n", myScores.finalScore);
					gameQuit = checkUserQuit();
				}
			}
		} // not gameOver

		exitGame(mySetup, code, myScores, myGameTime);
		if (!gameQuit)
		{
			checkDisplayTopBottom();
		}

	} // not gameQuit

	free(code);
	free(userGuess);
}
