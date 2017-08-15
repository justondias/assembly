;;;;;;; Info;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Lab 7 Solution Code
;Modified from original QFPV.asm 
;By Pattarapong Rojanasthien
;Last Update 4/5/2010
;;;;;;; Program hierarchy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mainline
;   Initial
;     InitLCD
;       LoopTime
;     DisplayC
;       T40
;   RPG
;   LEDCounter
;   LoopTime
;

;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        list  P=PIC18F452, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
        #include P18F452.inc
        __CONFIG  _CONFIG1H, _HS_OSC_1H  ;HS oscillator
        __CONFIG  _CONFIG2L, _PWRT_ON_2L & _BOR_ON_2L & _BORV_42_2L  ;Reset
        __CONFIG  _CONFIG2H, _WDT_OFF_2H  ;Watchdog timer disabled
        __CONFIG  _CONFIG3H, _CCP2MX_ON_3H  ;CCP2 to RC1 (rather than to RB3)
        __CONFIG  _CONFIG4L, _LVP_OFF_4L  ;RB5 enabled for I/O
        errorlevel -314, -315          ;Ignore lfsr messages

;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cblock  0x000                  ; Beginning of Access RAM
        COUNT                          ; Counter available as local to subroutines
        DELRPG                         ; Used DELRPG to let the programmer know whether
                                       ;  or not the RPG moved and at which direction 
                                       ;  (-1 for left or +1 for right).
        OLDPORTD                       ; Holds the old value of PortD to compare with
                                       ;  the new value. Used in RPG.
        BINCOUNT                       ; "Binary Count." Holds the value of the number 
                                       ;  currently being displayed in binary on LEDs D4 and D5.
        TEMPSTR:6                      ; String that hold the current temperature to be displayed on the LCD.
        HEXSTR:4                       ; String used to display the hex values located
                                       ;  on the right side of the LCD (output of the POT and the DAC)
        BYTE                           ; Temporary variable used for anything.
        RPGCNT                         ; Used internally for the RPG subroutine.
		RPGCOUNTER
        endc

#include c:\math18\mathvars.inc

;;;;;;; Macro definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; These are the binary variables used for the PButton subroutine.
ISC     equ 0                          ; Initiate screen change for long press.
ISA     equ 1                          ; Initiate secondary action for short press.
PDONE   equ 2                          ; Pushbutton action has been taken.
OLDPB   equ 3                          ; Old state of pushbutton.
NEWPB   equ 4                          ; New state of pushbutton.
PBthres equ 30                         ; Pushbutton threshold ofr a long press.


; Lets the programmer store a literal value in a RAM location directly.
;

MOVLF   macro  literal,dest
        movlw  literal
        movwf  dest
        endm

; Used to point TBLPTRH to a constant string (stored in program memory) so that 
; it can be displayed on the LCD.
;

POINT   macro  stringname
        MOVLF  high stringname, TBLPTRH
        MOVLF  low stringname,  TBLPTRL
        endm

;;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        org   0x0000                   ; Reset vector.
        nop 
        goto  Mainline

        org   0x0008                   ; High priority interrupt vector.
        goto  $                        ; If interrupt is generated, go into this infinite loop.

        org   0x0018                   ; Low priority interrupt vector.
        goto  $                        ; If interrupt is generated, go into this infinite loop.

;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mainline
        rcall  Initial                 ;Initialize everything.

        ;LOOP_
L1
          btg    PORTB,RB0             ; Toggles the B0/INT0 pin to measure the total time.  Should be 10ms.
          rcall  RPG                   ; Tests whether or not the RPG turned.
          rcall  LEDCounter            ; Tests D4 and D5 LEDs. 
          rcall  LoopTime              ; The remainder of the 10ms is spent in here by using Timer1.
        ;ENDLOOP_
        bra	L1
PL1

;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine performs all initializations of variables and registers.

Initial
        MOVLF B'01001110', ADCON1      ; Enable PORTA & PORTE digital I/O pins for the A/D converter.
        MOVLF B'01100001', ADCON0      ; Sets up the A/D converter for the POT.
        MOVLF B'11110001', TRISA       ; Set I/O for PORTA. '1' is input while '0' is output.
        MOVLF B'11011100', TRISB       ; Set I/O for PORTB.
        MOVLF B'11010010', TRISC       ; Set I/0 for PORTC.
        MOVLF B'00001111', TRISD       ; Set I/0 for PORTD.
        MOVLF B'00000100', TRISE       ; Set I/0 for PORTE.
        MOVLF B'00000000', PORTA       ; Turn off all four LEDs driven from PORTA.
        MOVLF B'00100000', SSPCON1     ; Sets up the SPI interface for the DAC
        MOVLF B'11000000', SSPSTAT     ;  to use with a 2.5 MHz clock.

                                       ; This sets up Timer1 and CCP1.
        MOVLF B'00001000', T3CON       ; Sets up so that T1 is used with CCP1.
        MOVLF B'10000001', T1CON       ; continue setting up T1 to CCP1.
        MOVLF B'00001011', CCP1CON     ; Set up to trigger special event so that PIR1, CCP1IF will be set.
        MOVLF B'01100001', CCPR1H      ; Set the comparator to 25,000.
        MOVLF B'10101000', CCPR1L	

                                       ; Initialize variables for RPG and PButton subroutines.
        movff PORTD, OLDPORTD          ; Initialize "old" value for RPG.
        clrf RPGCNT                    ; Initialize the RPG counter.


        clrf BINCOUNT

                                       ; Set up the characters that will not ever change

        MOVLF 0x00, HEXSTR+3           ; Terminating byte for HEXSTR will never change.
        rcall InitLCD                  ; Initialize LCD.
        POINT InitialDisplay           ; Display 'COUNT' on the LCD.
        rcall DisplayC		
		;Initialize the RPG Counter
		MOVLF 0x80,RPGCOUNTER
		MOVLF 0xC0,HEXSTR              ; Set the position of HEXSTR to the lower right hand corner of the LCD.
		movff RPGCOUNTER, BYTE 
		rcall HexDisplay
        return

;;;;;;; InitLCD subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Initialize the Optrex 8x2 character LCD.
; First wait for 0.1 second, to get past display's power-on reset time.

InitLCD
        MOVLF  10,COUNT                ; Wait 0.1 second.
        ;REPEAT_
L2
          rcall  LoopTime              ; Call LoopTime 10 times.
          decf   COUNT,F
        ;UNTIL_  .Z.
        bnz	L2
RL2

        bcf    PORTE,0                 ; RS=0 for command.
        POINT  LCDstr                  ; Set up table pointer to initialization string.
        tblrd*                         ; Get first byte from string into TABLAT.
        ;REPEAT_
L3
          bsf    PORTE,1               ; Drive E high.
          movff  TABLAT,PORTD          ; Send upper nibble.
          bcf    PORTE,1               ; Drive E low so LCD will process input.
          rcall  LoopTime              ; Wait ten milliseconds.
          bsf    PORTE,1               ; Drive E high.
          swapf  TABLAT,W              ; Swap nibbles.
          movwf  PORTD                 ; Send lower nibble.
          bcf    PORTE,1               ; Drive E low so LCD will process input.
          rcall  LoopTime              ; Wait ten milliseconds.
          tblrd+*                      ; Increment pointer and get next byte.
          movf   TABLAT,F              ; Is it zero?
        ;UNTIL_  .Z.
        bnz	L3
RL3
        return

;;;;;;; T40 subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Pause for 40 microseconds  or 40/0.4 = 100 clock cycles.
; Assumes 10/4 = 2.5 MHz internal clock rate.

T40
        movlw  100/3                   ; Each REPEAT loop takes 3 cycles.
        movwf  COUNT
        ;REPEAT_
L4
          decf  COUNT,F
        ;UNTIL_  .Z.
        bnz	L4
RL4
        return


;;;;;;;;DisplayC subroutine;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine is called with TBLPTR containing the address of a constant
; display string.  It sends the bytes of the string to the LCD.  The first
; byte sets the cursor position.  The remaining bytes are displayed, beginning
; at that position.
; This subroutine expects a normal one-byte cursor-positioning code, 0xhh, or
; an occasionally used two-byte cursor-positioning code of the form 0x00hh.

DisplayC
        bcf  PORTE,0                   ; Drive RS pin low for cursor-positioning code.
        tblrd*                         ; Get byte from string into TABLAT.
        movf TABLAT,F                  ; Check for leading zero byte.
        ;IF_  .Z.
        bnz	L5
          tblrd+*                      ; If zero, get next byte.
        ;ENDIF_
L5
        ;REPEAT_
L6
          bsf   PORTE,1                ; Drive E pin high.
          movff TABLAT,PORTD           ; Send upper nibble.
          bcf   PORTE,1                ; Drive E pin low so LCD will accept nibble.
          bsf   PORTE,1                ; Drive E pin high again.
          swapf TABLAT,W               ; Swap nibbles.
          movwf PORTD                  ; Write lower nibble.
          bcf   PORTE,1                ; Drive E pin low so LCD will process byte.
          rcall T40                    ; Wait 40 usec.
          bsf   PORTE,0                ; Drive RS pin high for displayable characters.
          tblrd+*                      ; Increment pointer, then get next byte.
          movf  TABLAT,F               ; Is it zero?
        ;UNTIL_  .Z.
        bnz	L6
RL6
        return

;;;;;;; DisplayV subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine is called with FSR0 containing the address of a variable
; display string.  It sends the bytes of the string to the LCD.  The first
; byte sets the cursor position.  The remaining bytes are displayed, beginning
; at that position.

DisplayV
        bcf  PORTE,0                   ; Drive RS pin low for cursor positioning code.
        ;REPEAT_
L7
          bsf   PORTE,1                ; Drive E pin high.
          movff INDF0,PORTD            ; Send upper nibble.
          bcf   PORTE,1                ; Drive E pin low so LCD will accept nibble.
          bsf   PORTE,1                ; Drive E pin high again.
          swapf INDF0,W                ; Swap nibbles.
          movwf PORTD                  ; Write lower nibble.
          bcf   PORTE,1                ; Drive E pin low so LCD will process byte.
          rcall T40                    ; Wait 40 usec.
          bsf   PORTE,0                ; Drive RS pin high for displayable characters.
          movf  PREINC0,W              ; Increment pointer, then get next byte.
        ;UNTIL_  .Z.                   ; Is it zero?
        bnz	L7
RL7
        return
        
;;;;;;; RPG subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine decyphers RPG changes into values of DELRPG of 0, +1, or -1.
; DELRPG = +1 for CW change, 0 for no change, and -1 for CCW change.

RPG
        clrf   DELRPG                  ; Clear for "no change" return value.
        movf   PORTD,W                 ; Copy PORTD into W.
        movwf  TEMP                    ;  and TEMP.
        xorwf  OLDPORTD,W              ; Any change?
        andlw  B'00000011'             ; If not, set the Z flag.
        ;IF_  .NZ.                     ; If the two bits have changed then...
        bz	L8
          rrcf OLDPORTD,W              ; Form what a CCW change would produce.
          ;IF_  .C.                    ; Make new bit 1 = complement of old bit 0.
          bnc	L9
            bcf  WREG,1
          ;ELSE_
          bra	L10
L9
            bsf  WREG,1
          ;ENDIF_
L10
          xorwf  TEMP,W                ; Did the RPG actually change to this output?
          andlw  B'00000011'
          ;IF_  .Z.                    ; If so, then change  DELRPG to -1 for CCW.
          bnz	L11
            decf DELRPG,F
          ;ELSE_                       ; Otherwise, change DELRPG to  +1 for CW.
          bra	L12
L11
            incf DELRPG,F
          ;ENDIF_
L12
        ;ENDIF_
L8
        movff  TEMP,OLDPORTD           ; Save PORTD as OLDPORTD for ten ms from now.
        return


;;;;;; HexDisplay subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine takes in BYTE and converts into an ASCII string in hex and stores it into
; HEXSTR for display.

HexDisplay
        rcall ConvertLowerNibble       ; Converts lower nibble of BYTE to hex and stores it in W.
        movwf HEXSTR+2                 ; Move the ASCII value into the most significant byte of HEXSTR.

        swapf BYTE,F                   ; Swap nibbles of BYTE to convert the upper nibble.

        rcall ConvertLowerNibble       ; Convert the old upper nibble of BYTE to hex and stores it in W.
        movwf HEXSTR+1                 ; Move the ASCII value into the 2nd byte of HEXSTR.

        lfsr  0, HEXSTR                ; Loads address of HEXSTR to fsr0 to display HEXSTR.
        rcall DisplayV                 ; Call DisplayV to display HEXSTR on LCD.
        return

;;;;;; ConvertLowerNibble subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine takes lower nibble of BYTE and converts it into its ASCII hex value.

ConvertLowerNibble                              
        movf BYTE, W                   ; Loads BYTE into W.
        andlw B'00001111'              ; Masks out the upper nibble.
        sublw 0x09                     ; Test if it's greater than 9. 
        ;IF_ .N.                       ; If, after masking, it is greater than 9, then it is a letter.
        bnn	L30
          movf BYTE,W                  ; Load BYTE into W.
          andlw B'00001111'            ; Mask out the upper nibble.
          addlw 0x37                   ; Add offset to obtain the letter's ASCII value.
        ;ELSE_                         ; If it's less than 9, then it's a number.
        bra	L31
L30
          movf BYTE,W
          andlw B'00001111'
          iorlw 0x30                   ; Then add offset of 30 to obtain the numeric's ASCII value.
        ;ENDIF_
L31
        return	




;;;;;;; LEDCounter subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; In this subroutine, the value of DELRPG is tested to see if there is any change in 
; RPG(or has it been turned).  DELRPG holds the value 1 if turned clockwise, 
; -1 if counter-clockwise, and 0 if there's no change.  Utilizing DELRPG and the variable
; BINCOUNT, the function is able to implement a counter.  The LEDs, D4 and D5, represents
; the RPG counting up or down (or turning clockwise or counter-clockwise).  Also, in 
; binary state, bit 0 of BINCOUNT represents the state of LED D5 and bit 1 represents D6.

LEDCounter
        movf  DELRPG,W                 ; Load DELRPG into W.                      
        sublw D'1'                     ; Subtract 1 from it to test for its value.
        ;IF_ .Z.                       ; If DELRPG was 1, 
        bnz	L34
          incf BINCOUNT,F              ; increment BINCOUNT.
          POINT UP           ; Display 'UP' on the LCD.
          rcall DisplayC		
		  INCF RPGCOUNTER
        ;ELSE_                         ; Otherwise, check to see if -1 was stored.
        bra	L35
L34
          movf DELRPG,W                ; load DELRPG into W to test for other cases.
          addlw D'1'                   ; Add 1 to W,
          ;IF_ .Z.                     ; and if 0(DELRPG = -1), 
          bnz	L36
            decf BINCOUNT,F            ; decrement BINCOUNT.
			POINT DOWN           ; Display 'UP' on the LCD.
          	rcall DisplayC
   		    DECF RPGCOUNTER
          ;ENDIF_
L36
        ;ENDIF_
L35
		MOVF  RPGCOUNTER,W
		RLNCF WREG,1
     	MOVWF PORTA
		MOVLF 0xC0,HEXSTR              ; Set the position of HEXSTR to the lower right hand corner of the LCD.
		movff RPGCOUNTER, BYTE 
		rcall HexDisplay
        return


;;;;;;; LoopTime subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Gives a 10ms looptime by using Timer1 and comparing it to 25,000.

LoopTime
        ;REPEAT_                       ; Repeat until TIMER1 has reached 25,000. 
L46
        ;UNTIL_ PIR1, CCP1IF == 1	       
        btfss PIR1,CCP1IF
        bra	L46
RL46
        bcf    PIR1, CCP1IF            ; When it has, reset it to start over.
        return

;;;;;;; Constant strings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LCDstr  		db  0x33,0x32,0x28,0x01,0x0c,0x06,0x00  ; Initialization string for LCD.
InitialDisplay	db  0x80,'C','O','U','N','T',0x00     ; Declaration of QFPV string on LCD.
UP			db 	0x80,'U','P',' ',' ',' ',0x00
DOWN			db 	0x80,'D','O','W','N',' ',0x00
        #include c:\math18\FXD2416U.INC
        #include c:\math18\FXD0808U.INC
        #include c:\math18\FXM1608U.INC

        end

