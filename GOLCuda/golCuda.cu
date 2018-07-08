/***********************
Conway Game of Life
Cuda version
************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "timer.h"
#include <cuda.h>

#define DATAFILE "../TestFiles/960.txt"
#define DIM 960 /*Dimension of input file*/
#define ITERS 150
#define CUDA_BLOCK_DIM 16 /*Dimension of cuda-blocks (how many threads in each direction)*/

/*Kernel to fill columns of the extra perimeter*/
__global__ void fill_columns(char* array)
{
    /*Find unique thread id*/
    int thread_id = blockDim.x * blockIdx.x + threadIdx.x;

    if(thread_id < DIM+2)
    {
        array[thread_id*(DIM+2)+DIM+1] = array[thread_id*(DIM+2)+1];
        array[thread_id*(DIM+2)] = array[thread_id*(DIM+2) + DIM];    
    }
}

/*Kernel to fill rows of the extra perimeter*/
__global__ void fill_rows(char* array)
{
    /*Find unique thread id*/
    int thread_id = blockDim.x * blockIdx.x + threadIdx.x + 1;

    if (thread_id < DIM+1)
    {
        array[(DIM+2)*(DIM+1)+thread_id] = array[(DIM+2)+thread_id];
        array[thread_id] = array[(DIM+2)*DIM + thread_id];
    }
}

__global__ void step(char* prev,char* next/*,int* global_cell_sum,int* flag*/)
{

  /*Shared memory between threads in a block*/
  __shared__ int shared_arr[CUDA_BLOCK_DIM][CUDA_BLOCK_DIM]; /*shared memory between threads in a block*/

  /*Thread id corresponding to the global array*/
  int x = blockIdx.x * (blockDim.x -2) + threadIdx.x;
  int y = blockIdx.y * (blockDim.y -2) + threadIdx.y;
  int thread_id = x + y*(DIM+2);

  /*Thread id corresponding to the local array*/
  int i = threadIdx.y;
  int j = threadIdx.x;
  int neighbors;
  
  /*int cell_sum = 0;*/ /*Number of alive cells at the next generation*/

  /*Copy elements into shared memory*/
  if ((x < (DIM+2)) && (y < (DIM+2))) shared_arr[i][j] = prev[thread_id];

  /*Wait until all threads write to the shared memory*/
  __syncthreads();

  /*Check if the thread id's are out of bounds*/
  if ((x < (DIM+1)) && (y < (DIM+1)) && (i != 0) && (i != (blockDim.y-1)) && (j != 0) && (j != (blockDim.x-1))){
      /*Calculate the number of neighbors*/
      neighbors = (shared_arr[i+1][j]-'0') + (shared_arr[i-1][j]-'0') + (shared_arr[i][j+1]-'0') + (shared_arr[i][j-1]-'0') + 
      (shared_arr[i+1][j+1]-'0') + (shared_arr[i-1][j-1]-'0') + (shared_arr[i-1][j+1]-'0') + (shared_arr[i+1][j-1]-'0');
              
      if((shared_arr[i][j] == '0') && (neighbors == 3)){
        next[thread_id] = '1';
        /*cell_sum++;*/
      }
      else if(shared_arr[i][j] == '1'){
      	if(neighbors < 2){
 	  next[thread_id] = '0';
	  /**flag = 1;*/
	}	
        else if(neighbors < 4){
          next[thread_id] = '1';
          /*cell_sum++;*/
        }
        else{
 	  next[thread_id] = '0';
          /**flag = 1;*/
	}
      }
      else next[thread_id] = '0';
  }
  
  /*atomicAdd(global_cell_sum,cell_sum);*/
}


int main(int argc, char* argv[])
{
  int i/*,n*/;
  char* h_array;   /*host array*/
  char* dev_array1; /*previous generation device array*/
  char* dev_array2; /*next generation device array*/
  char* temp_arr;
  double start,finish;
  
  int fd = open(DATAFILE, O_RDONLY);
  if(fd < 0){
    fprintf(stderr, "Could not open file \"%s\"\n", DATAFILE);
    return -1;
  }
   
  h_array = (char*)malloc((DIM+2)*(DIM+2)*sizeof(char));
  
  /*Read the grid from the file into the array, skipping positions that correspond to the perimeter*/
  i = DIM+3;
  while(read(fd,&h_array[i],DIM)){
    i += DIM+2;
  }
  close(fd);
 
  /*struct stat st = {0};
  if (stat("./generations", &st) == -1)
    mkdir("./generations", 0700);*/

  /*Block size and grid size for threads to fill rows and columns*/
  dim3 rc_block_size(CUDA_BLOCK_DIM);
  dim3 rows_grid_size((int)ceil((DIM)/(float)rc_block_size.x));
  dim3 cols_grid_size((int)ceil((DIM+2)/(float)rc_block_size.x));

  dim3 block_size(CUDA_BLOCK_DIM,CUDA_BLOCK_DIM); /*Each cuda block is 2-d and has CUDA_BLOCK_DIM*CUDA_BLOCK_DIM threads*/
  dim3 grid_size((int)ceil(DIM/(float)CUDA_BLOCK_DIM),(int)ceil(DIM/(float)CUDA_BLOCK_DIM)); /*Number of cuda blocks in the grid*/
  
  cudaMalloc((void **)&dev_array1,(DIM+2)*(DIM+2)*sizeof(char));
  cudaMalloc((void **)&dev_array2,(DIM+2)*(DIM+2)*sizeof(char));

  cudaMemcpy(dev_array1,h_array,(DIM+2)*(DIM+2)*sizeof(char),cudaMemcpyHostToDevice);
  
  /*int* cell_sum_dev;
  int* flag_dev;
  int cell_sum = 0;
  int flag = 0;

  cudaMalloc((void **)&cell_sum_dev,sizeof(int));
  cudaMalloc((void **)&flag_dev,sizeof(int));*/

  GET_TIME(start); 

  /*Start Iterations*/
  for(i = 0; i < ITERS; i++){

    /*char file_name[100];
    sprintf(file_name, "./generations/%dGen.txt",i+1);*/
 
    /*Fill the extra perimeter of the previous generation array*/
    fill_rows<<<rows_grid_size,rc_block_size>>>(dev_array1);
    fill_columns<<<cols_grid_size,rc_block_size>>>(dev_array1);
    
    /*cell_sum = 0;
    flag = 0;
   
    cudaMemcpy(cell_sum_dev,&cell_sum,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(flag_dev,&flag,sizeof(int),cudaMemcpyHostToDevice);*/

    /*Calculate the next game generation*/
    step<<<grid_size, block_size>>>(dev_array1,dev_array2/*,cell_sum_dev,flag_dev*/);

    /*Copy generation to cpu*/
    cudaMemcpy(h_array,dev_array2,(DIM+2)*(DIM+2)*sizeof(char),cudaMemcpyDeviceToHost);

    /*Copy reduction results to cpu*/
    /*cudaMemcpy(&cell_sum,cell_sum_dev,sizeof(int),cudaMemcpyDeviceToHost);
    cudaMemcpy(&flag,flag_dev,sizeof(int),cudaMemcpyDeviceToHost);*/

    /*Write the generation into a file*/
    /*int fd1 = open(file_name, O_RDWR | O_CREAT ,0666);
    if(fd1 < 0){
      fprintf(stderr, "Could not open file \"%s\"\n", file_name);
      return -1;
    }
  
    for(n = DIM+3;n < ((DIM+2)*(DIM+2))-(DIM+2);n+=DIM+2){
      write(fd1,&h_array[n],DIM);
      write(fd1,"\n",sizeof(char));
    }
    close(fd1);*/
    
    /*Terminate if grid is empty or hasnt changed*/
    /*if((cell_sum == 0) || (flag == 0)) break;*/

    /*Previous generation becomes next and vice versa*/
    temp_arr = dev_array1;
    dev_array1 = dev_array2;
    dev_array2 = temp_arr;
  }
  
  GET_TIME(finish);  

  printf("Elapsed time: %f seconds\n",finish-start);
  
  /*Free allocated resources at gpu and cpu*/
  cudaFree(dev_array1);
  cudaFree(dev_array2);
  free(h_array);

  return 0;
}  
  
  
