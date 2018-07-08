/***********************
Conway's Game of Life
Serial version
************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "timer.h"

#define NI 960       /* array sizes */
#define NJ 960
#define NSTEPS 150    /* number of time steps */
#define TESTFILE "../TestFiles/960.txt"

int main(int argc, char *argv[]) {

  int i, j, n, im, ip, jm, jp, ni, nj, nsum, isum;
  char **old, **new;  
  float x;
  char buffer[1024];
  double start,finish;

  /* allocate arrays */

  ni = NI + 2;  /* add 2 for left and right ghost cells */
  nj = NJ + 2;
  old = malloc(ni*sizeof(char*));
  new = malloc(ni*sizeof(char*));

  for(i=0; i<ni; i++){
    old[i] = malloc(nj*sizeof(char));
    new[i] = malloc(nj*sizeof(char));
  }

  FILE *fp;
  
  fp = fopen(TESTFILE,"r");

  for(i = 1; i <= NJ; i++)
        fread(&old[i][1],sizeof(char),NJ,fp);
  fclose(fp); 

  /*struct stat st = {0};
  if (stat("./generations", &st) == -1)
    mkdir("./generations", 0700);*/

  GET_TIME(start); 
   
  /*  time steps */
  for(n=0; n<NSTEPS; n++){

    /*char file_name[100];
    sprintf(file_name, "./generations/%dGeneration.txt",n+1);*/
    
    /* corner boundary conditions */
    old[0][0] = old[NI][NJ];
    old[0][NJ+1] = old[NI][1];
    old[NI+1][NJ+1] = old[1][1];
    old[NI+1][0] = old[1][NJ];

    /* left-right boundary conditions */
    for(i=1; i<=NI; i++){
      old[i][0] = old[i][NJ];
      old[i][NJ+1] = old[i][1];
    }

    /* top-bottom boundary conditions */
    for(j=1; j<=NJ; j++){
      old[0][j] = old[NI][j];
      old[NI+1][j] = old[1][j];
    }

    for(i=1; i<=NI; i++){
      for(j=1; j<=NJ; j++){
	im = i-1;
	ip = i+1;
	jm = j-1;
	jp = j+1;

	nsum =  (old[im][jp]-'0') + (old[i][jp]-'0') + (old[ip][jp]-'0')
	  + (old[im][j ]-'0')              + (old[ip][j]-'0') 
	  + (old[im][jm]-'0') + (old[i][jm]-'0') + (old[ip][jm]-'0');

	switch(nsum){

	case 3:
	  new[i][j] = '1';
	  break;

	case 2:
	  new[i][j] = old[i][j];
	  break;

	default:
	  new[i][j] = '0';
	}
      }
    }

    /*FILE *fi;
    fi = fopen(file_name,"w+");
 
    for(i = 1; i <= NJ; i++){
      fwrite(&new[i][1],sizeof(char),NJ,fi);
      fwrite("\n",sizeof(char),1,fi);
    }
    fclose(fi);*/

    /*copy new state into old state */
    for(i=1; i<=NI; i++){
      for(j=1; j<=NJ; j++){
	old[i][j] = new[i][j];
      }
    }
  }

  GET_TIME(finish);

  printf("Elapsed time: %f seconds\n",finish-start); 

  return 0;
}
