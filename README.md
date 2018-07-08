# Conway-s-Game-Of-Life

The Game of Life, also known simply as Life, is a cellular automaton devised by the British mathematician John Horton Conway in 1970

Implementation done within the course of the subject "Parallel Systems" during the summer of 2016-2017 by our team:

**Panagiotis Kokkinakos** , **Theodoros Stefou** , **Georgios Rouvalis** 

# Compilation and Run:

	Serial: Compile with $make and execute as follows: $./golSerial
	
	MPI: We also include the lines of code that make the reduction.
	Compile with $make and execute as follows: $mpiexec -f machines -n <Processes> ./golMpi
	
	OpenMP: We do not include the lines of code that make the reduction.
	Compile with $make and execute as follows: $mpiexec -f machines -n <Processes> ./golOpenMP
	
	Cuda: We have not included the lines of code that make the reduction.
	Compile with make and execute as follows: $./golCuda
