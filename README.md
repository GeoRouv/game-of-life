# Conway-s-Game-Of-Life

The Game of Life, also known simply as Life, is a cellular automaton devised by the British mathematician John Horton Conway in 1970

Implementation done within the course of the subject "Parallel Systems" during the summer of 2016-2017 by our team:

* **Panagiotis Kokkinakos** <br>
* **Theodoros Stefou** <br>
* **Georgios Rouvalis** <br>

## Compilation and Run:

	Before executing anything compile with:
	$ make
	
	* Serial: 
	$ ./golSerial
	
	* MPI(w/ reduction): 
	$ mpiexec -f machines -n <Processes> ./golMpi
	
	* OpenMP(w/o reduction): 
	$ mpiexec -f machines -n <Processes> ./golOpenMP
	
	* Cuda(w/o reduction): 
	$ ./golCuda
