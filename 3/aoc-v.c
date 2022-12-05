#include <stdio.h>
#include <string.h>


int main()
{

	int fd = open("input",0666);

	unsigned int score = 0;
	unsigned char buff = 0;
	unsigned char sack[72];
	unsigned char ch1[72];
	unsigned char ch2[72];
	int c = 0;

	int i = read(fd, &buff, 1);

	memset(&ch1, 0, 72);
	memset(&ch2, 0, 72);
	memset(&sack, 0, 72);

	while ( 1 )
	{
		while ( i > 0 )
		{
			if (buff != 0x0a)
			{
				sack[c++] = buff; 
			}
			else
			{
				if (c == 0) //end of rucksack found
					break;
				//printf("len: %d / 50% = %d\n", (c-1), ((c-1)/2));
				c = ( ( c - 1 ) / 2) ; //split count in half

				//parse halfs
				for(int index = 0; index < c; index++)
				{
					ch1[ ( ( sack[index] ) - 0x41 ) ] += 1;
					ch2[ ( ( sack[index + c] ) - 0x41 ) ] += 1;
				}

				//find pairs
				for(int index = 0; index < 72; index++)
				{
					if ((ch1[index]>0) && (ch2[index]>0))
					{
						/*
						if (((index) - 0x1f) < 0)
							printf("%c %x %d\n", index+0x41, index+0x41, index + 27);
						else
							printf("%c %x %d\n", index+0x41, index+0x41, (index) - 0x1f);
						*/
						score += ( ((index - 0x1f) < 0) ? (index + 27) : ( index - 0x1f ) ) ;
					}
				}

				c = 0;
				//reset memory.
				memset(&ch1, 0, 72);
				memset(&ch2, 0, 72);
				memset(&sack, 0, 72);
			}
			i = read(fd, &buff, 1);
		}
		if (c == 0) break;
	}

	printf("AOC-C Verification:\n");
	printf("My Score: %d\n", score);
	
}
