CC = gcc

all:golOpenMP ../SerialToVertical/ConvertVert

golOpenMP:golOpenMP.c
	mpicc -g -Wall -std=c99 -fopenmp -o golOpenMP golOpenMP.c -lm

../SerialToVertical/ConvertVert: ../SerialToVertical/ConvertVert.c
	$(CC) -o ../SerialToVertical/ConvertVert ../SerialToVertical/ConvertVert.c


