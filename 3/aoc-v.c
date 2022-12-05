#include <stdio.h>
#include <string.h>

unsigned char sacks[3][66];

char dupItem(int sc)
{
	int sLen = sacks[sc][64];
	for(int ix = 0; ix < (sLen / 2); ix++)
	{
		for(int jx = (sLen / 2); jx < sLen; jx++)
		{
			if (sacks[sc][ix] == sacks[sc][jx])
			{
				if ((sacks[sc][ix] - 0x61) < 0)
				{
					return ( sacks[sc][ix] - 0x41 ) + 27;
				}
				else
				{
					return ( sacks[sc][ix] - 0x61 ) + 1;
				}
			}
		}
	}
}

int readLine(int fd, int sc)
{
	unsigned char buff = 0;
	int i = read(fd, &buff, 1);
	while ( buff != 0x0a || i <=0 )
	{
		sacks[ sc ][ sacks[ sc ][ 64 ] ] = buff;
		sacks[ sc ][ 64 ] = sacks[ sc ][ 64 ] + 1;
		i = read(fd, &buff, 1);
		if (i <= 0) 
			return i;
	}
	return 1;
}

char getBadge() {
    for (int ix = 0; ix < sacks[0][64]; ix++) 
    {
        for (int jx = 0; jx < sacks[1][64]; jx++) 
        {
            for (int kx = 0; kx < sacks[2][64]; kx++) 
            {
                if (sacks[0][ix] == sacks[1][jx] && sacks[1][jx] == sacks[2][kx]) 
                {
                	if ((sacks[0][ix] - 0x61) < 0)
					{
						return ( sacks[0][ix] - 0x41 ) + 27;
					}
					else
					{
						return ( sacks[0][ix] - 0x61 ) + 1;
					}
                }
            }
        }   
    }
    return 0;
}

int main()
{
	int fd = open("input",0666);
	int sackCount = 3;
	int myScore = 0;
	int myScore2 = 0;
	for(int ix = 0; ix<sackCount; ix++) sacks[ ix ][ 64 ] = 0;
	sackCount=0;

	int readLineStatus = 0;
	while ( 1 ) 
	{
		readLineStatus = readLine(fd, sackCount);
		sackCount = sackCount + 1;
		if ((readLineStatus <= 0) || (sackCount == 3))
		{
			for( int sci = 0; sci <= sackCount; sci++ ) myScore += dupItem(sci);
			
			myScore2+=getBadge();

			for(int ix = 0; ix<sackCount; ix++) sacks[ ix ][ 64 ] = 0;
			sackCount = 0;
		}

		if (readLineStatus <= 0) break;
	}
	printf("AOC-C Verification:\n");
	printf("My Score: %d\n", myScore);
	printf("My Score2: %d\n", myScore2);
	exit(0);
}
