list P=PIC18F452, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
#include P18F452.inc 




#include c:\math18\mathvars.inc

;;;;;;;;;;;;;;;;;;;VARIABLES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CBLOCK 0x000
	COUNT
   	ENTRYS:8
    BYTE
	HBYTE
    LBYTE
	ANS
	ANS2
	diff
	gdiff
	FSADADARR

ENDC

;;;;;;;;;;;;;;;;;;;MACROS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVLF macro input, dest 
    MOVLW input 
    MOVWF dest 
ENDM

POINT macro stringname
    MOVLF high stringname, TBLPTRH
    MOVLF low stringname,  TBLPTRL
ENDM

;;;;;;;;;;;;;;;;;;;MAIN CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 0x0000
GOTO Main

Main
    RCALL Initialize
   	RCALL startmsg
	RCALL gen

	guessss
    POINT Start
    RCALL DisplayC
	RCALL counter
   	RCALL display
    RCALL Timer10
	rcall check
	cat
	BTFSS PORTD,3
	GOTO guessss
	goto cat



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check
MOVFF ANS2, WREG
SUBWF ANS, WREG
MOVWF diff

MOVFF LBYTE, WREG
SUBWF HBYTE, WREG
MOVWF gdiff

MOVFF diff, WREG
SUBWF gdiff, WREG
BZ same

MOVFF diff, WREG
XORWF gdiff, W
BZ yes
BRA nope

yes
POINT dog
rcall DisplayC
rcall Delay35s
goto Main

nope
POINT no
rcall DisplayC
goto cat

same
MOVFF ANS, WREG
XORWF HBYTE, W
BZ yes
BRA nope

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

startmsg
	POINT go
   	RCALL DisplayC
	RCALL Timer10
	POINT lo
    RCALL DisplayC
	RCALL Timer10
return

pressmsg
	POINT again
   	RCALL DisplayC
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

counter
rcall scoop
movwf HBYTE
MOVLW 0x00
mat
BTFSS PORTD,3
GOTO cont
goto mat
cont
rcall scoop
movwf LBYTE
return

scoop
rcall row1
MOVF WREG,W
BNZ ok
rcall row2
MOVF WREG,W
BNZ ok
rcall row3
MOVF WREG,W
BNZ ok
rcall row4
MOVF WREG,W
BNZ ok
BZ scoop
ok
return




display
	LFSR 0, ENTRYS+1
	MOVFF HBYTE,ENTRYS+1
	LFSR 0, ENTRYS+2
	MOVFF LBYTE,ENTRYS+2
    LFSR 0, ENTRYS
    MOVLF 0xC0, ENTRYS 
    MOVLF A' ', ENTRYS+3
    MOVLF A' ', ENTRYS+4
    MOVLF A' ', ENTRYS+5
    MOVLF A' ', ENTRYS+6
    MOVLF A' ', ENTRYS+7
	MOVLF A' ', ENTRYS+8
    RCALL DisplayV
RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

generate
movlw A'0'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'1'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'2'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'3'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'4'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'5'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'6'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'7'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'8'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'9'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'A'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'B'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'C'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'D'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'E'
BTFSS PORTD,3
return
RCALL Timer10
movlw A'F'
BTFSS PORTD,3
return
RCALL Timer10
goto generate


gen
rcall generate
MOVWF ANS
RCALL deb
lop
RCALL pressmsg
BTFSS PORTD,3
goto nextt
goto lop
nextt
RCALL deb
rcall generate
MOVWF ANS2
goto guessss


deb
BCF	INTCON,TMR0IF      
MOVLW	46004/256
MOVWF	TMR0H
MOVLW	46004%256
MOVWF	TMR0L
MOVLW	B'10000110'
MOVWF	T0CON
	
Check2s	
BTFSS	INTCON,TMR0IF
GOTO	Check2s
BCF   INTCON,TMR0IF
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Initialize
	bcf	INTCON2,7
    MOVLF B'11001110', ADCON1
    MOVLF B'11100001', TRISA
    MOVLF B'00000100', TRISE
    MOVLF B'11011111', TRISB
    MOVLF B'11000010', TRISC
    MOVLF B'00001011', TRISD
    RCALL InitLCD 
	MOVLF 0x01, COUNT	
RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


row1	;scan row 1
bcf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bsf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW A'3'
btfSS PORTB,2
RETLW A'2'
btfss PORTB,1
RETLW A'1'
btfss PORTB,0
RETLW A'0'
RETLW 0x00
return


row2	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bcf PORTC,3	
bsf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW A'7'
btfSS PORTB,2
RETLW A'6'
btfss PORTB,1
RETLW A'5'
btfss PORTB,0
RETLW A'4'
RETLW 0x00
return

row3	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bcf PORTC,4	
bsf PORTC,5	

btfss PORTB,3
RETLW A'B'
btfSS PORTB,2
RETLW A'A'
btfss PORTB,1
RETLW A'9'
btfss PORTB,0
RETLW A'8'
RETLW 0x00
return

row4	;scan row 1
bsf PORTC,2	;set appropriate values for C* pins, refer to Figure 6.2
bsf PORTC,3	
bsf PORTC,4	
bcf PORTC,5	

btfss PORTB,3
RETLW A'F'
btfSS PORTB,2
RETLW A'E'
btfss PORTB,1
RETLW A'D'
btfss PORTB,0
RETLW A'C'
RETLW 0x00
return





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;INITLCD SUBROUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitLCD
    MOVLF 10, COUNT 
    Loop1
        RCALL Timer10
        DECF COUNT, F
        BNZ Loop1
    BCF PORTE, 0 
    POINT LCDstr 
    TBLRD*
    Loop2
        BSF PORTE,1 
        MOVFF TABLAT,PORTD 
        BCF PORTE,1 
        RCALL Timer10 
        BSF PORTE,1 
        SWAPF TABLAT,W 
        MOVWF PORTD 
        BCF PORTE,1 
        RCALL Timer10 
        TBLRD+* 
        MOVF TABLAT,F 
    BNZ Loop2
RETURN

;;;;;;;;;;;;;;;;;;;DISPLAYC SUBROUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayC
    BCF PORTE,0 
    TBLRD* 
    MOVF TABLAT,F 
    BNZ Loop4
    TBLRD+* 
    Loop4
        BSF PORTE,1 
        MOVFF TABLAT,PORTD 
        BCF PORTE,1 
        BSF PORTE,1 
        SWAPF TABLAT,W 
        MOVWF PORTD 
        BCF PORTE,1 
        RCALL Timer40 
        BSF PORTE,0 
        TBLRD+* 
        MOVF TABLAT,F 
        BNZ Loop4
RETURN

;;;;;;;;;;;;;;;;;;;DISPLAYV SUBROUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayV
    BCF PORTE,0
    Loopp
        BSF PORTE,1 
        MOVFF INDF0, PORTD 
        BCF PORTE,1 
        BSF PORTE,1 
        SWAPF INDF0,W 
        MOVWF PORTD 
        BCF PORTE,1 
        RCALL Timer40 
        BSF PORTE,0
        MOVF PREINC0,W 
    BNZ Loopp
RETURN


;;;;;;;;;;;;;;;;;;;CONSTANT STRINGS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LCDstr db  0x33,0x32,0x28,0x01,0x0c,0x06,0x00
Start db 0x80, 'g','u','e','s','s',' ',' ',' ', 0x00
clr db 0x80, ' ',' ',' ',' ',' ',' ',' ',' ', 0x00
dog db 0x80, 'Y','O','U',' ','W','I','N','!', 0x00
no db 0x80, 'n','o','p','e',' ',' ',' ',' ', 0x00
go db 0x80, 'p','r','e','s','s','S','W','3', 0x00
lo db 0xC0, 't','o',' ','s','t','a','r','t', 0x00
again db 0xC0, 'a','g','a','i','n','!',' ',' ', 0x00
      
;;;;;;;;;;;;;;;;;;;TIMERS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Delay35s	
BCF	INTCON,TMR0IF      
MOVLW	31356/256
MOVWF	TMR0H
MOVLW	31356%256
MOVWF	TMR0L
MOVLW	B'10000111'
MOVWF	T0CON
	
Check35s	
BTFSS	INTCON,TMR0IF
GOTO	Check35s
BCF   INTCON,TMR0IF
RETURN	


Timer40
    MOVLW  100/3                   
    MOVWF  COUNT
    Loop3
        DECF  COUNT, F
        BNZ    Loop3    
RETURN

Timer10
    BCF INTCON,TMR0IF
    MOVLF 40536/256, TMR0H
    MOVLF 40536%256, TMR0L
    MOVLF B'10001000', T0CON
    Check10ms
        BTFSS INTCON, TMR0IF
        GOTO Check10ms
    BCF INTCON, TMR0IF
RETURN

TimerS
    BCF INTCON, TMR0IF
    MOVLF 6072/256, TMR0H
    MOVLF 6072%256, TMR0L
    MOVLF B'10000001', T0CON
    CheckS
        BTFSS INTCON, TMR0IF
        GOTO CheckS
    BCF INTCON, TMR0IF
RETURN 

#include c:\math18\FXD2416U.INC
#include c:\math18\FXD0808U.INC
#include c:\math18\FXM1608U.INC






END