#include <stdio.h>

int main()
{

	int fd = open("input",0666);

	char buff = 0;
	int celf = 0;
	int belf = 0;
	int belf1 = 0;
	int belf2 = 0;
	int sum = 0;
	int count = 0;

	int i = read(fd, &buff, 1);

	while ( i > 0 )
	{
		if ( ((buff-0x30)<=9) && ((buff-0x30)>=0) )
		{
			sum = (sum*10) + (buff-0x30);
			count++;
		}
		else
		{
			if (count == 0)
			{
				//printf("%d %d \n", celf, belf);
				if (celf > belf2)
				{
					belf2 = celf;
				}

				if (celf > belf1)
				{
					belf2 = belf1;
					belf1 = celf;
				}

				if (celf > belf)
				{
					belf2 = belf1;
					belf1 = belf;
					belf = celf;
				}
				celf = 0;
				sum = 0;
				count = 0;

			}
			else
			{
				celf += sum;
				sum = 0;
				count = 0;
			}
		}
		i = read(fd, &buff, 1);
	}

	printf("AOC-C Verification:\n");
	printf("Highest Elf Cals is: %d\n", belf);
	printf("3 Highest Elf Cals is: %d %d %d\n", belf,belf1,belf2);
	printf("Combined 3 Highest is: %d\n", belf+belf1+belf2);

}
