list P=PIC18F452, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
#include P18F452.inc 

MOVLF macro input, dest 
    MOVLW input 
    MOVWF dest 
ENDM

POINT macro stringname
    MOVLF high stringname, TBLPTRH
    MOVLF low stringname,  TBLPTRL
ENDM


org 0x0000
GOTO MAIN
MAIN 
RCALL initialize

scoop
rcall row1
rcall row2
rcall row3
rcall row4
rcall loop
goto scoop

loop
MOVWF PORTA
return

row1	;scan row 1
bcf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bsf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW b'00000110'
btfSS PORTB,2
RETLW b'00000100'
btfss PORTB,1
RETLW b'00000010'
btfss PORTB,0
RETLW b'00000000'
return


row2	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bcf PORTC,3	
bsf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW b'00001110'
btfSS PORTB,2
RETLW b'00001100'
btfss PORTB,1
RETLW b'00001010'
btfss PORTB,0
RETLW b'00001000'
return

row3	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bcf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW b'00001110'
btfSS PORTB,2
RETLW b'00001110'
btfss PORTB,1
RETLW b'00001110'
btfss PORTB,0
RETLW b'00001110'
return

row4	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bsf PORTC,4	
bcf PORTC,5	

btfss PORTB,3
RETLW b'00001110'
btfSS PORTB,2
RETLW b'00001110'
btfss PORTB,1
RETLW b'00001110'
btfss PORTB,0
RETLW b'00001110'
return




;
;initialize
;bcf	INTCON2,7
;MOVLW 0x00
;MOVWF TRISC
;MOVLW 0xFF
;MOVWF TRISB
;MOVLW 0x00
;MOVWF TRISA
;MOVWF b'11111111'
;MOVLW PORTB
;return

initialize
	bcf	INTCON2,7
    MOVLF B'11001110', ADCON1
    MOVLF B'11100001', TRISA
    MOVLF B'00000100', TRISE
    MOVLF B'11011111', TRISB
    MOVLF B'11000010', TRISC
    MOVLF B'00000011', TRISD
return
END