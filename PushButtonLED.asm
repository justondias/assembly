list P=PIC18F452, F=INHx32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON 

#INCLUDE P18f452.inc ; 

			
ORG	0x0000		
GOTO	Main
				
Main	

	
	MOVLW B'11111111'
	MOVWF TRISD
	
;at the end of the program, use the following instruction 
END 
