CC = gcc

all:golMpi ../SerialToVertical/ConvertVert

golMpi: golMpi.c
	mpicc -g -Wall -std=c99 -o golMpi golMpi.c -lm

../SerialToVertical/ConvertVert: ../SerialToVertical/ConvertVert.c
	$(CC) -o ../SerialToVertical/ConvertVert ../SerialToVertical/ConvertVert.c


