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


time_t startTime = 0;
time_t currentTime = 0;
int numOfTrials = 0;
int B = 0;
int W = 0;
double cumScore = 0;
int timeRemaining = 0;
int minutes = 0;
int seconds = 0;
double finalScore = 0;
bool userQuit = false;


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


/*
 * Description:
 */
void initializeGame (char *playerName, int mode, int rows, int columns,
					int numOfColours, int trials, clock_t startTime, char code[rows][columns])
{
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
	if (seconds > 9)
	{
		printf("  B   W   R   S   T\n");
		printf(" %d  %d  %d  %.2f  %d:%d\n", B, W, numOfTrials, cumScore, minutes, seconds);
	}
	else
	{
		printf("  B   W   R   S   T\n");
		printf(" %d  %d  %d  %.2f  %d:0%d\n", B, W, numOfTrials, cumScore, minutes, seconds);
	}

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
	/* add in a transcript file. read assignment */
}

/*
 * Description: run exitGame functions
 */
bool exitGame()
{
	char checkPlayAgain[50];
	char *string1;

	printf("Final Score: %.2f\n", finalScore);


	if (!userQuit){
		do{
			printf("Please enter 1 to Play Again\n"
					"or $ to Exit\n");
			fgets(checkPlayAgain, 50, stdin);																	// takes user input

			printf("checkPlayAgain is %s\n", checkPlayAgain);
				/* Citation: https://www.geeksforgeeks.org/strtok-strtok_r-functions-c-examples/ */
				string1 = strtok(checkPlayAgain, " ");																// removes spaces from string

		}
		while (checkPlayAgain[0] != '1' || checkPlayAgain[0] != '$');

		if (string1 != NULL)																			// ensures string is not NULL
		{
				if (string1[0] == '$')													// checking for user quit
				{
					userQuit = true;
				}
				else if (string1[0] == '1')															// getting row number
				{
					return false;
				}
		}




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
}

/*
 * Description: The bottom n scores do not include negative infinities
 */
void displayBottom(int numOfBottom)
{
	printf( "Display Bottom - TODO\n");
}

bool checkUserInput(int N, int M, int C, int R, int T)
{
	bool inputStatus = true;

	if (N < 1)
	{
		printf("Input Error: N must be greater than or equal to one.\n");
		inputStatus = false;
	}

	if (C <= 4)
	{
		printf("Input Error: C must be greater than or equal to five.\n");
		inputStatus = false;
	}

	if (M > C)
	{
		printf("Input Error: M must be greater than or equal to C.\n");
		inputStatus = false;
	}

	if (R < 1)
	{
		printf("Input Error: R must be greater than or equal to one.\n");
		inputStatus = false;
	}

	if (T < 0)
	{
		printf("Input Error: T must be greater than zero.\n");
		inputStatus = false;
	}
	return inputStatus;
}

bool getGuessInput(int rows, int columns,char userGuess[rows][columns])
{

	char inputString[100]= {0};
	char tmpString[100] = {0};

	int i = 0;

	do
	{
		inputString[i] = getchar();
		i++;
	}
	while(inputString[i-1] != '\n');

	inputString[i-1] = 0;								// null terminate string

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
	char playerName[20];					// command line input player name
	int N,
		M,
		C,
		R,
		T,
		mode;



	time_t t;
	srand( (unsigned) time(&t) );

	bool validInput = false;
	do
	{
		printf( "Please enter Player Name, N, M, C, R, and T values\n" );
		//scanf("%s %d %d %d %d %d", playerName, &N, &M, &C, &R, &T); 		  TODO uncomment
		strcpy(playerName,"Jada");											//TODO delete from
		N = 1;
		M = 5;
		C = 6;
		R = 5;
		T = 1;																//TODO delete to

		//TODO playername input validation

		//printf( "Player Name: %s, N: %d, M: %d, C: %d, R: %d, and T: %d\n", playerName, N, M, C, R, T);

		validInput = checkUserInput(N, M, C, R, T);
	}
	while(!validInput);

	T = T * 60; 								// get time in seconds

	bool modeSelect = false;
	do
	{
		printf("Please select a mode:\n"
				"   Enter 0 to Play\n"
				"   Enter 1 to Test\n");
		//scanf("%d", &mode);				TODO uncomment
		mode = 1;							//TODO delete

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

	char (*code)[M] = malloc(N * M * sizeof(code[0][0]));	// allocate memory for code
	char (*userGuess)[M] = malloc(N * M * sizeof(code[0][0]));	// allocate memory for code

	initializeGame(playerName, mode, N, M, C, R, startTime, code);
	findTime(T);


	bool gameOver = false;


	do
	{
		numOfTrials++;
		printf( "Enter your guess below:\n");
		getGuessInput(N, M, userGuess);

		if (userQuit)										// userQuit
		{
			printf("    --> User Quit \n");
			gameOver = exitGame();
		}

		calculateScore(R, T, N,  M, code, userGuess);
		displayHints();

		if (B == N*M)
			{
				printf("    --> Cracked!\n");
				logScore(playerName);
				gameOver = exitGame();
			}

		if (numOfTrials > R- 1){
				finalScore = finalScore * -1;
				logScore(playerName);
				printf("    --> num of trials exceeded\n");
				gameOver = exitGame();
			}

		if(minutes > (double)T)
			{
				logScore(playerName);
				printf("    --> time exceeded\n");
				gameOver = exitGame();
			}








	}
	while(!gameOver);

	free(code);
}




















