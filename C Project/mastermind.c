/*
 * mastermind.c
 *
 *  Created on: May 25, 2021
 *      Author: jadal
 *      UCID: 30016807
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


time_t startTime = 0;
time_t currentTime = 0;
int numOfTrials = 0;
int B = 0;
int W = 0;
double cumScore = 0;
int timeRemaining = 0;
int hours = 0;
int minutes = 0;
int seconds = 0;
double finalScore = 0;
bool userQuit = false;
bool playAgain = false;
bool gameOver = false;

char playerName[20];					// command line input player name
int rows,
	columns,
	numOfColours,
	maxTrials,
	maxTime,
	mode;


/*
 * Description: Random number generator
 *
 * @param	lowerBound for the random number generator
 * 			upperBound for the random number generator
 * 			neg TODO
 *
 * @returns random integer within the bounds
 */
int randomNum (int lowerBound, int upperBound)
{
	return (rand() % (upperBound + 1 - lowerBound) + lowerBound);	// returns a random number within lower & upper bounds
}

/*
 * Description:  returns a letter (color) based on an integer value n
 */
char colour(int n)
{
	char newColour = (char) n + 'A';		// convert # to A-Z ASCII to represent color

	return newColour;
}

/*
 * Description: to find how much time has elapsed
 *
 * CITATION: https://www.techiedelight.com/find-execution-time-c-program/
 */
void findTime(int maxTime)
{
	if (startTime == 0)
	{
		time(&startTime);
	}
	else
	{
		time(&currentTime);
		time_t temp = difftime(currentTime, startTime);

		timeRemaining = maxTime - temp;

		if (timeRemaining > 0)
		{
			minutes = timeRemaining / 60;
			seconds = (timeRemaining - (minutes * 60));
		}
		else
		{
			timeRemaining = 0;
		}
	}
}

bool checkUserInput()
{
	bool inputStatus = true;

	if (rows < 1)
	{
		printf("Input Error: N must be greater than or equal to one.\n");
		inputStatus = false;
	}

	if (columns <= 4)
	{
		printf("Input Error: C must be greater than or equal to five.\n");
		inputStatus = false;
	}

	if (columns > numOfColours)
	{
		printf("Input Error: M must be greater than or equal to C.\n");
		inputStatus = false;
	}

	if (maxTrials < 1)
	{
		printf("Input Error: R must be greater than or equal to one.\n");
		inputStatus = false;
	}

	if (maxTime < 0)
	{
		printf("Input Error: T must be greater than zero.\n");
		inputStatus = false;
	}

	return inputStatus;
}

/*
 * Description:
 */
void initializeGame (char code[rows][columns])
{
	startTime = 0;
	currentTime = 0;
	numOfTrials = 0;
	B = 0;
	W = 0;
	cumScore = 0;
	timeRemaining = 0;
	minutes = 0;
	seconds = 0;
	finalScore = 0;
	userQuit = false;
	playAgain = false;
	gameOver = false;

	playerName[20] = 0;					// command line input player name
	rows = 0;
	columns = 0;
	numOfColours = 0;
	maxTrials = 0;
	maxTime = 0;
	mode = 0;


		time_t t;
		srand( (unsigned) time(&t) );

		bool validInput = false;
		do
		{
			printf( "Please enter Player Name, N, M, C, trials, and T values\n" );

#if 1
			scanf("%s %d %d %d %d %d", playerName, &rows, &columns, &numOfColours, &maxTrials, &maxTime); 		 // TODO uncomment
#else
			strcpy(playerName,"Jada");											//TODO delete from
			rows = 1;
			columns = 5;
			numOfColours = 6;
			maxTrials = 5;
			maxTime = 1;																//TODO delete to
#endif
			//TODO playername input validation

			//printf( "Player Name: %s, N: %d, M: %d, C: %d, R: %d, and maxTime: %d\n", playerName, rows,columns, numOfColours, maxTrials, maxTime);

			validInput = checkUserInput();
		}
		while(!validInput);

		maxTime = maxTime * 60; 								// get time in seconds

		bool modeSelect = false;
		do
		{
			printf("Please select a mode:\n"
					"   Enter 0 to Play\n"
					"   Enter 1 to Test\n");

			scanf("%d", &mode);				//TODO uncomment
			//mode = 1;							//TODO delete

			//TODO mode input validation check for non integers

			if (mode == 1 || mode == 0)
			{
				modeSelect = true;
			}
			else
			{
				printf("Input Error: Please enter 1 or 0.\n");
			}
		}
		while(!modeSelect);

	if (mode == 1)
	{
		printf("Hello %s!\nRunning Mastermind in test mode\n", playerName);
	}
	else
	{
		printf("Hello %s!\nRunning Mastermind in play mode\n", playerName);

	}

	for (int i = 0; i < rows; i++ )
	{
		for (int j = 0; j < columns; j++)
		{
			int randNum = randomNum( 0, numOfColours - 1);
			code[i][j] = colour(randNum);
			printf(" %c ", code[i][j]);
		}
	}

	if (mode == 1)
	{
		printf("Hidden code is: ");

		for (int i = 0; i < rows; i++ )
		{
			for (int j = 0; j < columns; j++)
			{
				printf(" %c ", code[i][j]);			//TODO fix print for when N > 1 lines
			}
			printf("\n");
		}
	}

	printf("Start cracking...\n");

	for (int i = 0; i < rows; i++ )
	{
		for (int j = 0; j < columns; j++)
		{
			printf("- ");
		}
		printf("\n");
	}

	printf("  B   W   R   S   T\n");
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
void displayHints()
{
	printf("  B   W   R   S   T\n");
	printf(" %d  %d  %d  %.2f  %d:%02d\n", B, W, numOfTrials, cumScore, minutes, seconds);
}

void findBW(int rows, int columns, char code[rows][columns], char userGuess[rows][columns])
{
	char tmpCode[rows][columns];
	char tmpUserGuess[rows][columns];

	B = 0;
	W = 0;

	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			tmpCode[i][j] = code[i][j];
		}
	}

	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			tmpUserGuess[i][j] = userGuess[i][j];
		}
	}

	for (int i = 0; i < rows; i++)
		{
			for (int j = 0; j < columns; j++)
			{
				if (tmpUserGuess[i][j] == tmpCode[i][j])			//TODO fix this for row checking bc user input is 1d array not 2d
				{
					B++;
					tmpUserGuess[i][j] = '0';						// set to 0 to avoid future match
					tmpCode[i][j] = '1';							// set to 1 to avoid future match
				}
			}
		}

	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			char colour = tmpUserGuess[i][j];

			for (int x = 0; x < rows; x++)
			{
				for (int y = 0; y < columns; y++)
				{
					if (colour == tmpCode[x][y])
					{
						W++;
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
void calculateScore( int R, int T, int rows, int columns, char code[rows][columns], char userGuess[rows][columns])
{
	findBW(rows, columns, code, userGuess);

	// S- calculate cumulative score
	double stepScore = (B + (W/ 2)) / numOfTrials;			// calculate stepscore

	cumScore += stepScore;

	findTime(T);

	finalScore = (cumScore/ numOfTrials) * timeRemaining * 1000;
}

/*
 * Description: Records player names and score in log file
 *
 * @param	*playerName holds the userInput player name
 * 			score holds the current score
 * 			time holds how long the game was
 */
void logScore(char *playerName)
{
	/* add in time */
	/* users who do not finish the game are not included in the returned list */

	FILE *fp;
	fp = fopen("mastermind.log", "a+");											// creates/ adds to log file
	fprintf(fp,"%s %f %d:%d\n", playerName, finalScore, minutes, seconds);			// records player name and score in log file
}

/*
 * Description:addition, a transcript file is created that
 *  records the game played (the steps in each move as shown on the screen
 */
void transcribeGame(int rows, int columns, char code[rows][columns])
{
	hours = startTime / 3600;
	minutes = (startTime -(3600* hours)) / 60;
	seconds = (startTime -(3600* hours) - (minutes * 60));
/*
	FILE *fp;
	char transcribeName = "%s_%02d:%02d:%02d", *playerName, hours, seconds, minutes;
	fp = fopen(transcribeName, "a+");

*/
}

/*
 * Description: run exitGame functions
 */
bool exitGame()
{
	char checkPlayAgain[50];
	char *string1;

	printf("Final Score: %.2f\n", finalScore);

	bool validInput = false;
	if (!userQuit)
	{
		do
		{
			printf("Please enter 1 to Play Again\n"
					"or $ to Exit\n");
			fgets(checkPlayAgain, 50, stdin);																	// takes user input

				/* Citation: https://www.geeksforgeeks.org/strtok-strtok_r-functions-c-examples/ */
				string1 = strtok(checkPlayAgain, " ");																// removes spaces from string

			if (string1 != NULL)																			// ensures string is not NULL
			{
				if (string1[0] == '$')													// checking for user quit
				{
					userQuit = true;
					validInput = true;
				}
				else if (string1[0] == '1')															// getting row number
				{
					userQuit = false;
					playAgain = true;
					return false;
				}
			}
		}
		while (!validInput);
	}

	return true;
}

/*
 * Description: user can also ask to display the top or bottom n scores
 *  before or after any game, including player names and duration.
 */
void displayTop(int numOfTop)
{
	printf( "Display Top - TODO\n");

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
		printf("%s %f %s\n", tmpName, tmpScore, tmpDuration);

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
	        }
		}
	}

    for (int i = 0; i < numOfTop; i++)
    {
    	 printf("%s %f %s\n", name[i], score[i], duration[i]);
    }
}


/*
 * Description: The bottom n scores do not include negative infinities
 */
void displayBottom(int numOfBottom)
{
	printf( "Display Bottom - TODO\n");
}



bool getGuessInput(int rows, int columns,char userGuess[rows][columns])
{
	char inputString[100]= {0};
	char tmpString[100] = {0};

#if 0
	int i = 0;										//TODO delete

	do
	{
		inputString[i] = getchar();
		i++;
	}
	while(inputString[i-1] != '\n');


	inputString[i-1] = 0;								// null terminate string
#else
	do
	{
		fgets(inputString, 100, stdin);
	}
	while (inputString[0] == '\n');								// ignore NULL input

#endif

// CITATION: https://stackoverflow.com/questions/13084236/function-to-remove-spaces-from-string-char-array-in-c
	for (int i = 0, j = 0; i<strlen(inputString); i++,j++)                        // Evaluate each character in the input
	{
		if (inputString[i] != ' ')
		{
			tmpString[j] = inputString[i];     	// If the character is not a space
		}	                                        // Copy that character to the output char[]
		else
		{
			 j--;
		}		                                   // If it is a space then do not increment the output index (j), the next non-space will be entered at the current index
	 }

//TODO input validation that inputstring contains enough guesses

	//  TODO ensure there are enough characters entered and within the color range


	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			userGuess[i][j] = tmpString[i*columns + j];
		}
	}

	if (userGuess[0][0] == '$')
	{
		userQuit = true;
	}

	return true;
}

/*
 * Description: Prompts user input, initializes, maintains, and terminates the game
 *
 * @param	argc argument count that holds the number of strings pointed
 * 			*argv argument vector
 *
 */
int main( int argc, char *argv[] )
{

	char (*code)[columns] = malloc(rows * columns * sizeof(code[0][0]));	// allocate memory for code
	char (*userGuess)[columns] = malloc(rows * columns * sizeof(code[0][0]));	// allocate memory for code

	initializeGame(code);
	findTime(maxTime);

	int numOfTop = 3;

	displayTop(numOfTop);

	do
	{
		numOfTrials++;
		printf( "Enter your guess below:\n");
		getGuessInput(rows, columns, userGuess);

		if (userQuit)										// userQuit
		{
			printf("    --> User Quit \n");
			gameOver = exitGame();
		}

		calculateScore(maxTrials, maxTime, rows, columns, code, userGuess);
		displayHints();

		if (B == rows*columns)
			{
				printf("    --> Cracked!\n");
				logScore(playerName);
				gameOver = exitGame();
			}

		if (numOfTrials > maxTrials- 1){
				finalScore = finalScore * -1;
				logScore(playerName);
				printf("    --> num of trials exceeded\n");
				gameOver = exitGame();
			}

		if(minutes > (double)maxTime)
			{
				logScore(playerName);
				printf("    --> time exceeded\n");
				gameOver = exitGame();
			}

		if (playAgain)
		{
			initializeGame(code);
			findTime(maxTime);
		}
	}
	while(!gameOver);

	free(code);
	free(userGuess);
}




















