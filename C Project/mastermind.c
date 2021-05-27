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


/*
 * Description: Random number generator
 *
 * @param	lowerBound for the random number generator
 * 			upperBound for the random number generator
 * 			neg TODO
 *
 * @returns random integer within the bounds
 */
int randomNum (int lowerBound, int upperBound, bool *negPtr)
{
	srand(time(0));													// seeds a random number generator
	int num =  rand() % (upperBound + 1 - lowerBound) + lowerBound;

	if (num < 0)
	{
		*negPtr = true;			//TODO its in the assignment but why do we need this?
	}

	return num;		// returns a random number generated within the lower and upper bounds
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
double findTime(clock_t startTime, double timeElapsed)
{
	 clock_t currentTime = clock();
	 timeElapsed = (double)(currentTime - startTime) / CLOCKS_PER_SEC;

	 timeElapsed = timeElapsed / 60;

	return timeElapsed;
}


/*
 * Description:
 */
void initializeGame (char *playerName, int mode, int rows, int columns,
					int numOfColours, int trials, clock_t startTime, char code[rows][columns])
{
	bool neg = false;


	for (int i = 0; i < rows; i++ )
	{
		for (int j = 0; j < columns; j++)
			{
				code[i][j] = colour( randomNum(0 , numOfColours - 1, &neg));				// 65-90 to get capital char values
			}
	}


	printf("code[0][0] is %c\n", code[0][0]);

	if (mode == 1)
	{
		printf("Hello %s!\nRunning Mastermind in test mode\n", playerName);
	}
	else
	{
		printf("Hello %s!\nRunning Mastermind in play mode\n", playerName);

	}

	if (mode == 1)
	{
		printf("Hidden code is: ");

		/* to print each letter of the code
		for (int i = 0; i < row; i++)
		{
			for (int j = 0; j < column; j++)
			{
				printf("%s ", code[i][j]);
			}
		}
		*/


	}

	startTime = clock();
}

/*
 * Description: check if game has ended
 */
void checkScore()
{

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
void displayHints(int  B, int W, int R, int S, int T)
{

}

/*
 * Description: returns overall score
 */
void calculateScore(int RColRSlot, int RColWSlot, int numOfTrials, int cumScore, int time)
{
	// B- calculate
	// W- calculate
	numOfTrials++;// counting trial number	TODO make sure you account for when this hits max trials(R)
	int stepScore = (RColRSlot + (RColWSlot/ 2)) / numOfTrials;		// calculate stepscore
	cumScore = cumScore + stepScore; 							// S- calculate cumulative score
	// T- calculate remaining time


	// call checkScore();
	// call displayHints();
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
void exitGame()
{
	// call logScore()
	// end transcribeGame() ??
	// display score() and or end/exit game message?
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
	if (N >= 1)
	{
		if (M <=C)
		{
			if (C >= 5)
			{
				if (R >=1)
				{
					if (T > 0)
					{
						return true;
					}
					else
					{
						printf("Input Error: T must be greater than zero.\n");
						return false;
					}
				}
				else
				{
					printf("Input Error: R must be greater than or equal to one.\n");
					return false;
				}
			}
			else
			{
				printf("Input Error: C must be greater than or equal to five.\n");
				return false;
			}
		}
		else
		{
			printf("Input Error: M must be greater than or equal to C.\n");
			return false;
		}
	}
	else
	{
		printf("Input Error: N must be greater than or equal to one.\n");
		return false;
	}
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

	int numOfTrials;
	clock_t startTime;
	double timeElapsed;


	bool validInput = false;
	do
	{
		printf( "Please enter Player Name, N, M, C, R, and T values\n" );
		scanf("%s %d %d %d %d %d", playerName, &N, &M, &C, &R, &T);

//TODO playername input validation

		printf( "Player Name: %s, N: %d, M: %d, C: %d, R: %d, and T: %d\n", playerName, N, M, C, R, T);

		validInput = checkUserInput(N, M, C, R, T);
	}
	while(!validInput);


	bool modeSelect = false;
	do
	{
		printf("Please select a mode:\n"
				"Enter 0 to Play\n"
				"Enter 1 to Test\n");
		scanf("%d", &mode);

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
	findTime(startTime, timeElapsed);
	printf("Time is: %f\n", timeElapsed);



	free(code);
}




















