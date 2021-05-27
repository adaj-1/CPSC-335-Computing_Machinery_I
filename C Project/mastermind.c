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
	sleep(1);

	srand(time(0));									// seeds a random number generator

	return rand() % (upperBound + 1 - lowerBound) + lowerBound;	// returns a random number generated within the lower and upper bounds
}

/*
 * Description:  returns a letter (color) based on an integer value n
 */
char colour(int n)
{
	char newColour = (char) n + 'A';

	return newColour;
}

/*
 * Description: to find how much time has elapsed
 *
 * CITATION: https://www.techiedelight.com/find-execution-time-c-program/
 */
double findTime(double timeElapsed)
{
	time(&currentTime);
	timeElapsed = difftime(currentTime, startTime);

	timeElapsed = timeElapsed/ 60;		//getting time in minutes
	return timeElapsed;
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

	time(&startTime);
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
void displayHints(int B, int W, int R, double S, double T)
{
	printf("  B   W   R   S   T\n");
	printf(" %d  %d  %d  %.2f  %.2f\n", B, W, R, S, T);
}


/*
 * Description: returns overall score
 */
void calculateScore(int R, int numOfTrials, double cumScore,int T, double time,
					int rows, int columns, char code[rows][columns], char userGuess[])
{
	// B- calculate
	int B = 0;

	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			if (userGuess[j] == code[i][j])			//TODO fix this for row checking bc user input is 1d array not 2d
			{
				B++;
			}
		}
	}

	// W- calculate
	int W = 0;
	for (int i = 0; i < strlen(userGuess); i++)
		{
			for (int j = 0; j < rows; j++)
			{
				for (int x = 0; x < columns; x++)
				{
					if (userGuess[i] == code[j][x])
					{
						if (i != x)								//TODO coded for 1d array
						{
							W++;
						}
					}
				}
			}
		}


	// S- calculate cumulative score
	double stepScore =(B + (W/ 2)) / numOfTrials;		// calculate stepscore
	printf("stepScore: %.2f", stepScore);

	cumScore = cumScore + stepScore;

	time = findTime(time);

	/* checkScore
	if (numOfTrials > R){
		//exitGame();
	}

	if(time > (double)T)
	{
		//exitGame();
	}
	*/


	displayHints(B, W, numOfTrials, cumScore, time);
}

/*
 * Description: Records player names and score in log file
 *
 * @param	*playerName holds the userInput player name
 * 			score holds the current score
 * 			time holds how long the game was
 */
void logScore(char *playerName, int score, int time)
{
	/* add in time */
	/* users who do not finish the game are not included in the returned list */

	FILE *fp;
	fp = fopen("mastermind.log", "a+");					// creates/ adds to log file
	fprintf(fp,"%s %d\n", playerName, score);			// records player name and score in log file
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
	// call logScore()
	// end transcribeGame() ??
	// display score() and or end/exit game message?
	return false;
}

/*
 * Description: user can also ask to display the top or bottom n scores
 *  before or after any game, including player names and duration.
 */
void displayTop(int numOfTop)
{

}

/*
 * Description: The bottom n scores do not include negative infinities
 */
void displayBottom(int numOfBottom)
{

}

bool checkUserInput(int N, int M, int C, int R, int T)
{
	if (N < 1)
	{
		printf("Input Error: N must be greater than or equal to one.\n");
		return false;
		if (C <= 4)
		{
			printf("Input Error: C must be greater than or equal to five.\n");
			return false;
			if (M > C)
			{
				printf("Input Error: M must be greater than or equal to C.\n");
				return false;
				if (R < 1)
				{
					printf("Input Error: R must be greater than or equal to one.\n");
					return false;
					if (T < 0)
					{
						printf("Input Error: T must be greater than zero.\n");
						return false;
					}
				}
			}
		}
	}
		return true;
}

char* formatUserInput(char *userGuess)
{
	char inputString[100]= {0};

	printf( "Enter your guess below:\n");

	int i = 0;
	do
	{
		inputString[i] = getchar();
		i++;
	}
	while(inputString[i-1] != '\n');

	inputString[i-1] = 0;

	printf("inputString is: %s\n", inputString);

// CITATION: https://stackoverflow.com/questions/13084236/function-to-remove-spaces-from-string-char-array-in-c
		for (int i = 0, j = 0; i<strlen(inputString); i++,j++)                        // Evaluate each character in the input
	{
		if (inputString[i]!=' ')
		{
			userGuess[j] = inputString[i];     // If the character is not a space
		}	                                        // Copy that character to the output char[]
		else
		{
			 j--;
		}		                                   // If it is a space then do not increment the output index (j), the next non-space will be entered at the current index
	 }

	printf("userInput is: %s\n", userGuess);

	return userGuess;
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
	int S = 0;

	double timeElapsed = 0;
	char userGuess[100] = {0};

	bool validInput = false;
	do
	{
		printf( "Please enter Player Name, N, M, C, R, and T values\n" );
		//scanf("%s %d %d %d %d %d", playerName, &N, &M, &C, &R, &T); 		  TODO uncomment
		strcpy(playerName,"Jada");											//TODO delete from
		N = 1;
		M = 5;
		C = 8;
		R = 12;
		T = 1;																//TODO delete to

//TODO playername input validation

		//printf( "Player Name: %s, N: %d, M: %d, C: %d, R: %d, and T: %d\n", playerName, N, M, C, R, T);

		validInput = checkUserInput(N, M, C, R, T);
	}
	while(!validInput);


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

	char (*code)[M] = malloc(N * M * sizeof(code[0][0]));;

	initializeGame(playerName, mode, N, M, C, R, startTime, code);
	findTime(timeElapsed);
	printf("Time is: %f\n", timeElapsed);							//TODO delete

	int deletecounter = 0;											//TODO delete

	char testInput[100] = {0};

	do
	{
		numOfTrials++;
		strcpy(testInput, formatUserInput(userGuess));
		calculateScore(R, numOfTrials, S, T, timeElapsed, N,  M, code, testInput);

		deletecounter++;
	}
	while(deletecounter < 3);


	free(code);
}




















