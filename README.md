
1.  Open MPLAB, start new project
2.  copy/paste the given code 
3.  compile it
4.  open TeraTerm
5.	connect to PIC18 
6.	adjust settings (baud rate=19200 and  msec/line=20)
7.	hit f3 to send hex file
8.	hit f7 to run program



Thermometer/Potentiometer------------------
Program converts thermometer uses ADC to display temperature in F on lcd.
Potentiometer read by DAC increments LEDs.

AdressingTypes.asm---------------------------------

HEX-Number-Guessing-Game-W-Answers.asm-------------
Program uses Keypad and lcd screen to make HEX number guessing game.
Randonly generates HEX value between 00 and FF shown on lcd
User guesses and higher or lower is displayed on lcd.
Game ends when value is correctly guessed and promts user to play again.
Note: The correct answer will be shown in the bottom corner in this version

Keypad.asm-----------------------------------------
Program integrates the keypad so when pressed, values 1-7 display as binary values by the LED's. 
If 8 or a letter is pressed all LED's remain on/ turn on.

LEDBinaryCounter.asm-------------------------------
Program creates a binary counter using LEDs D4, D5, and D6 and uses the button SW3 to increment the counter

LEDTimers.asm	-------------------------------------
Program using delays to make  D4 light for 2s,  D5 light for 3.5s, and  D6 light for 5s. Loops indefinitely. 

PushButtonLED.asm----------------------------------
program using delays to turn on LEDs D4, D5, and D6 while SW3 is held down.

RPG_LED.asm----------------------------------------


lcd.asm--------------------------------------------	

rpg.asm--------------------------------------------

