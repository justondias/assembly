list P=PIC18F452, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
#include P18F452.inc ;

CBLOCK 
	cat

ENDC 

			
ORG	0x0000		
GOTO	Main
				
Main	

rcall initialize

loop
BTFSS PORTD,3
rcall on
goto loop

on
INCF cat
RLNcF cat 
MOVFF cat, PORTA
RRNcF cat

BCF	INTCON,TMR0IF      
MOVLW	100/128
MOVWF	TMR0H
MOVLW	100%128
MOVWF	TMR0L
MOVLW	B'10000001'
MOVWF	T0CON
	
Check2s	
BTFSS	INTCON,TMR0IF
GOTO	Check2s
BCF   INTCON,TMR0IF

chair
BTFSC PORTD,3
return
goto chair





initialize
MOVLW B'11111111' 
MOVWF TRISD 
MOVLW B'00000000'
MOVWF TRISA
CLRF cat
return



END 
