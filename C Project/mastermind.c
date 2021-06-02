/*
 * updatedMastermind.c
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

#define MY_POS_INFINITY 9999999
#define MY_NEG_INFINITY -9999999


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

struct GameTime
{
	time_t startTime;
	int timeRemaining;
	int hours;
	int minutes;
	int seconds;
};

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
void findTime(int maxTimeSec, struct GameTime *gameTime)
{
	time_t currentTime;
	time(&currentTime);

	time_t temp = difftime(currentTime, gameTime->startTime);

	gameTime->timeRemaining = maxTimeSec - temp;

	if (gameTime->timeRemaining > 0)
	{
		gameTime->minutes = gameTime->timeRemaining / 60;
		gameTime->seconds = (gameTime->timeRemaining - (gameTime->minutes * 60));
	}
	else
	{
		gameTime->timeRemaining = 0;
	}
}

void initializeGame (struct UserSetup setup,
					 char code[setup.rows][setup.columns],
					 struct GameTime *gameTime,
					 struct AllScores *scores)
{
	time(&gameTime->startTime);

	gameTime->timeRemaining = 0;
	gameTime->hours = 0;
	gameTime->minutes = 0;
	gameTime->seconds = 0;

	scores->B = 0;
	scores->W = 0;
	scores->numOfTrials = 0;
	scores->cumScore = 0;
	scores->finalScore = 0;

	time_t t;
	srand( (unsigned) time(&t) );

	if (setup.mode == 1)
	{
		printf("Hello %s!\nRunning Mastermind in test mode\n", setup.playerName);
	}
	else
	{
		printf("Hello %s!\nRunning Mastermind in play mode\n", setup.playerName);
	}

	for (int i = 0; i < setup.rows; i++ )
	{
		for (int j = 0; j < setup.columns; j++)
		{
			int randNum = randomNum( 0, setup.numOfColours - 1);
			code[i][j] = colour(randNum);
			printf(" %c ", code[i][j]);					//TODO delete
		}
	}
	printf("\n");										//TODO delete

	if (setup.mode == 1)
	{
			printf("Hidden code is: ");

			for (int i = 0; i < setup.rows; i++ )
			{
				for (int j = 0; j < setup.columns; j++)
				{
					printf(" %c ", code[i][j]);			//TODO fix print for when N > 1 lines
				}
				printf("\n");
			}
		}

		printf("Start cracking...\n");

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
void displayHints(struct GameTime gameTime, struct AllScores score)
{
	printf("  B   W   R   S   T\n");
	printf(" %d  %d  %d  %.2f  %d:%02d\n", score.B,
										   score.W,
										   score.numOfTrials,
										   score.cumScore,
										   gameTime.minutes,
										   gameTime.seconds);
}

void findBW(struct UserSetup setup,
			char code[setup.rows][setup.columns],
			char userGuess[setup.rows][setup.columns],
			struct AllScores *score)
{
	char tmpCode[setup.rows][setup.columns];
	char tmpUserGuess[setup.rows][setup.columns];

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
				if (tmpUserGuess[i][j] == tmpCode[i][j])			//TODO fix this for row checking bc user input is 1d array not 2d
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
		printf("Cracked!\n");
		return true;
	}

	if (score->numOfTrials > setup.maxTrials- 1)
	{
		score->finalScore = score->finalScore * -1;
		printf("Trials exceeded.\n");
		return true;
	}

	if(gameTime->minutes > (double)setup.maxTime)
	{
		printf("Time exceeded.\n");
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
void transcribeGame(struct UserSetup setup,
					char code[setup.rows][setup.columns])
{
	//hours = startTime / 3600;
	//minutes = (startTime -(3600* hours)) / 60;
	//seconds = (startTime -(3600* hours) - (minutes * 60));
/*
	FILE *fp;
	char transcribeName = "%s_%02d:%02d:%02d", *playerName, hours, seconds, minutes;
	fp = fopen(transcribeName, "a+");

*/
}

void exitGame(struct UserSetup setup,
		char code[setup.rows][setup.columns],
		struct AllScores score,
		struct GameTime gameTime)
{
	logScore(setup, score, gameTime);
	transcribeGame(setup, code);
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
		printf("----> in quit\n");
		return true;
	}
	else
	{
		printf("----> in guessed\n");
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
		scanf("%s %d %d %d %d %d",  mySetup.playerName,						//TODO delete
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

	printf("----> %s %d %d %d %d %d\n", mySetup.playerName,						//TODO delete
										mySetup.rows,
										mySetup.columns,
										mySetup.numOfColours,
										mySetup.maxTrials,
										mySetup.maxTime);

	bool modeSelect = false;
	do
	{
		printf("Please select a mode: Play (0) or Test (1)\n");
		scanf("%d", &mySetup.mode);				//TODO uncomment
		//mode = 1;								//TODO delete

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
				displayHints(myGameTime, myScores);
				if (gameOver)
				{
					printf("Final Score: %.2f\n", myScores.finalScore);
					gameQuit = checkUserQuit();
				}
			}
		} // not gameOver
		//TODO call exitGame() to do log file
		//TODO transcript
		exitGame(mySetup, code, myScores, myGameTime);
		checkDisplayTopBottom();
	} // not gameQuit

	free(code);
	free(userGuess);
}
