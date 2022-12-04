#include <stdio.h>

/*
A Y
B X
C Z
This strategy guide predicts and recommends the following:

In the first round, your opponent will choose Rock (A), and you should choose Paper (Y). This ends in a win for you with a score of 8 (2 because you chose Paper + 6 because you won).

In the second round, your opponent will choose Paper (B), and you should choose Rock (X). This ends in a loss for you with a score of 1 (1 + 0).

The third round is a draw with both players choosing Scissors, giving you a score of 3 + 3 = 6.

In this example, if you were to follow the strategy guide, you would get a total score of 15 (8 + 1 + 6).
*/


// 6 points for win
// 3 points for draw
// 0 points for lose

//4 bytes per link 
//[Opponent Move] [space] [YourMove] [newine]


int main()
{

	int fd = open("input",0666);

	int score = 0;
	int score2 = 0;

	unsigned int buff = 0;

	unsigned char scoreMatrix[3][3] = 
	{ 
		//A for Rock, B for Paper, and C for Scissors
		//Y for Paper, X for Rock, Z for Scissors

		//{R + D, P + W, S + L}, //Opponent Rock : A
		{1 + 3, 2 + 6, 3 + 0},

		//{R + L, P + D, S + W}, //Opponent Paper : B
		{1 + 0, 2 + 3,3 + 6},

		//{R + W, P + L, S + D}  //Opponent Scissors : C
		{1 + 6, 2 + 0, 3 + 3} 
	};

	unsigned char scoreMatrix2[3][3] = 
	{ 
		//A for Rock, B for Paper, and C for Scissors
		//X for Lose, Y for Draw, Z for Win

		//1 for Rock, 2 for Paper, and 3 for Scissors
		//0 for lost, 3 for draw, and 6 for win

		//{L + S, D + R, W + P}, //Opponent Rock : A
		  {0 + 3, 3 + 1, 6 + 2},

		//{L + R, D + P, W + S}, //Opponent Paper : B
		  {0 + 1, 3 + 2, 6 + 3},

		//{L + P, D + S, W + R}  //Opponent Scissors : C
		  {0 + 2, 3 + 3, 6 + 1} 
	};

	int i = read(fd, &buff, 4);

	while ( i > 0 )
	{	
		if (((buff>>24) != 0x0a) && (((buff>>8)&0xff) != 0x20))
			break;

		unsigned char O = ( (buff & 0xff) - 0x41 );
		unsigned char M = ( ( (buff>>16) & 0xff ) - 0x58);

		score += scoreMatrix[O][M];
		score2 += scoreMatrix2[O][M];
		//printf("%c(%d) %c(%d) %x %d\n",O+0x41,O, M+0x58,M, scoreMatrix[O][M],score); 

		i = read(fd, &buff, 4);
	}

	printf("AOC-C Verification:\n");
	printf("My Score: %d\n", score);
	printf("My Score2: %d\n", score2);

}
