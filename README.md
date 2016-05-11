echo
===
This is a rewrite of GNU's 'echo' program (/bin/echo) in Assembly that is 99.4% smaller (196 bytes vs 31296 bytes). It only has one argument, '-n', which removes the newline at the end.  
  
Some benchmarks:  
Lots of arguments:  
0th place: ./ASM32/echo  
	Real: 0.2393  
	User: 0.008  
	System: 0.0  

1st place: ./GNU32/echo  
	Real: 0.09989999999999989  
	User: 0.0126  
	System: 0.0003 
  
2nd place: ./GNU64/echo  
	Real: 0.10069999999999991  
	User: 0.0136  
	System: 0.0005  
  
Results (one long argument):  
0th place: ./ASM32/echo  
	Real: 0.2458  
	User: 0.0009  
	System: 0.0  
  
1st place: ./GNU64/echo  
	Real: 0.10679999999999991  
	User: 0.0042  
	System: 0.0  
  
2nd place: ./GNU32/echo  
	Real: 0.10659999999999988  
	User: 0.0043  
	System: 0.0  
