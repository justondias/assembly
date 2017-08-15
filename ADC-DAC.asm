;;;;;;;;;;;;;;;;;;;ASSEMLER DIRECTIVES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

list  P=PIC18F452, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
        #include P18F452.inc
;        __CONFIG  _CONFIG1H, _HS_OSC_1H  
;        __CONFIG  _CONFIG2L, _PWRT_ON_2L & _BOR_ON_2L & _BORV_42_2L 
;        __CONFIG  _CONFIG2H, _WDT_OFF_2H  
;        __CONFIG  _CONFIG3H, _CCP2MX_ON_3H  
;        __CONFIG  _CONFIG4L, _LVP_OFF_4L  
;        errorlevel -314, -315          

#include c:\math18\mathvars.inc

;;;;;;;;;;;;;;;;;;;VARIABLES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CBLOCK 0x000
    COUNT
    TEMPSTR:6
    BYTE
	HBYTE
    CELSIUS:4
	POTVALUE
	POTV:6
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
MainLoop
    POINT Start
    RCALL DisplayC
    RCALL ReadTemp
    RCALL TempDisplay
	RCALL ReadPot
	RCALL POTDisplay
    BCF ADCON1, ADFM
    RCALL Timer10
GOTO MainLoop

;;;;;;;;;;;;;;;;;;;INITIALIZE SUBROUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Initialize
    MOVLF B'11001110', ADCON1
    
    MOVLF B'11100001', TRISA
    MOVLF B'00000100', TRISE
    MOVLF B'11011111', TRISB
    MOVLF B'11000010', TRISC
    MOVLF B'00000011', TRISD

    RCALL InitLCD 
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadPot
 	
	ReadPot
	MOVLF B'11100001', ADCON0 
	bsf ADCON0, GO_DONE ; Begins the A/D conversion. ;Wait until A/D conversion is finished.
	RCALL Timer40
	WaitADC
	btfsc ADCON0,GO_DONE 
	bra WaitADC
	movff ADRESH,BYTE ;Move the upper byte from the A/D into POTVALUE. return
	movff ADRESH,HBYTE 
	MOVLW 0xFF
	MULWF BYTE

	
	
	return

POTDisplay
    LFSR 0, POTV+4
    Loop5
        CLRF WREG
        MOVFF BYTE, AARGB0
        MOVLF D'10', BARGB0
        CALL FXD0808U
        MOVF REMB0, W
        IORLW 0x30
        MOVWF POSTDEC0
        MOVFF AARGB0, BYTE
        MOVF FSR0L, W
        SUBLW low POTV
    BNZ Loop5
    LFSR 0, POTV
    MOVLF 0xC0, POTV 
   ; MOVLF A' ', POTV+4
    MOVLF A'V', POTV+5
    MOVLF A' ', POTV+6
    MOVLF A' ', POTV+7
    RCALL DisplayV
RETURN



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
    Loop6
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
    BNZ Loop6 
RETURN

;;;;;;;;;;;;;;;;;;;TEMPERATURE SUBROUTINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadTemp
    MOVLF B'01000001', ADCON0 
    BSF ADCON1, ADFM 
    RCALL Timer40
    BSF ADCON0, GO_DONE 

    WaitADCTemp
        BTFSC ADCON0, GO_DONE
    BRA WaitADCTemp
    
    MOVLF 0x03, AARGB0 
    MOVLF 0xE8, AARGB1
    MOVFF ADRESL, BARGB0 
    CALL FXM1608U
    MOVLF 0x08, BARGB0 
    MOVLF 0x00, BARGB1
    CALL FXD2416U
    MOVFF AARGB2, BYTE
RETURN

TempDisplay
    LFSR 0, TEMPSTR+2
    Loop77
        CLRF WREG
        MOVFF BYTE, AARGB0
        MOVLF D'10', BARGB0
        CALL FXD0808U
        MOVF REMB0, W
        IORLW 0x30
        MOVWF POSTDEC0
        MOVFF AARGB0, BYTE
        MOVF FSR0L, W
        SUBLW low TEMPSTR
    BNZ Loop77
    LFSR 0, TEMPSTR
    MOVLF 0x80, TEMPSTR 
    MOVLF 0xDF, TEMPSTR+3
    MOVLF A'F', TEMPSTR+4
    MOVLF A' ', TEMPSTR+5
    MOVLF A' ', TEMPSTR+6
    MOVLF A' ', TEMPSTR+7
    RCALL DisplayV
RETURN

;;;;;;;;;;;;;;;;;;;CONSTANT STRINGS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LCDstr db  0x33,0x32,0x28,0x01,0x0c,0x06,0x00
Start db 0x80, ' ',' ',' ',' ',' ',' ',' ',' ', 0x00
      
;;;;;;;;;;;;;;;;;;;TIMERS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

