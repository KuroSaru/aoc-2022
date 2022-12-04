#include <stdio.h>

int main()
{

	int fd = open("input",0666);

	int score = 0;

	char[][] scoreMatrix = 
	[ 
		[0,1,2],
		[0,1,2],
		[0,1,2]
	];

	int i = read(fd, &buff, 4);

	while ( i > 0 )
	{

		i = read(fd, &buff, 4);
	}

	printf("AOC-C Verification:\n");
	printf("My Score: %d\n", belf);

}
