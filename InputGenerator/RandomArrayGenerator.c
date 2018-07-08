#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* This program creates a random array with 0 and 1 */

int main(int argc, char* argv[])
{
	if(argc != 3)
		return -1;

	srand(3);

	int i,j;
	int size = atoi(argv[2]);
	if(size <= 0){
		fprintf(stderr, "%s: Size must be greater than zero.\n", argv[0]);
		return -1;
	}

	char* filename = argv[1];
	FILE *fp;
	fp = fopen(filename, "w");
	if(fp == NULL){
		fprintf(stderr, "%s: Could not open file \"%s\"\n", argv[0], argv[2]);
		return -1;
	}

	for(i = 0; i < size; i++)
	{
		for(j = 0; j < size; j++)
		{
			if( rand() % 10 <= 5 )
				fprintf(fp, "0");
			else
				fprintf(fp, "1");
                                                     
		}

		//fprintf(fp, "\n");
	}

	fclose(fp);

	return 0;

}
