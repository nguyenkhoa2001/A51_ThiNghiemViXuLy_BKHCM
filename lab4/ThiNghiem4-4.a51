; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 4
;   ThiNghiem4
;   TARGET: sending charater to LCD display and send back to terminal
;
;
LCD_E	    BIT		P3.3
LCD_RS	    BIT 	P3.5
LCD_ADDRESS	    EQU		6000H
;
;	
ORG 2000H
; SET-UP TO READY FOR TRANSMITTING AND FOR LCD
; FIRST SET-UP FOR SMOD BIT = 1 ON PCON REGISTER
	MOV A, PCON       
	SETB ACC.7
	MOV PCON, A
; SET-UP timer 1 mode 2 for generate baud rate 19200 bps ;
	MOV TMOD, #20H
	MOV TH1, #-3
	MOV TL1, #-3
	MOV SCON, #01010010B
	SETB TR1
; SETUP FOR LCD
	MOV DPTR,#LCD_ADDRESS
	ACALL CLEAR_LCD
	ACALL INIT_LCD
MAIN:
	CLR A                   ; delete A to get new charater
	ACALL IN_CHAR           ; get letter from terminal and stored it to A
	ACALL WRITE_CHAR        ; display the letter to the display on LCD
	ACALL OUT_CHAR          ; send back the letter to the terminal
	SJMP MAIN               ; loop back for new character

	SJMP $
; END OF MAIN
; SOME PROCEDURE FOR MAIN PROGRAM
; SETTING FOR TX, RX
; SERIAL PORT'S PROCEDURE
OUT_CHAR:
	JNB TI, $
	CLR TI
	MOV SBUF, A
	RET
	
IN_CHAR:
	JNB RI, $
	CLR RI
	MOV A, SBUF
	RET
;
; ************************************************
; *                 LCD PROCEDURE                *
; ************************************************
;
CLEAR_LCD:
; this procedure will wipeout all display on LCD
; this won't affect any register
; command #01H is "Clear display" command in documentation
    PUSH ACC
    MOV A, #01H
    ACALL WRITE_COM
    POP ACC
    RET

INIT_LCD:
; this procedure will configure some properties in LCD in the first time start
; this rocedure won't affect any register
;   command #38H will be the function set: #0011 1000 B
;       - 8 bit interface
;       - two row mode
;       - 5x7 dot format
    PUSH ACC
    MOV A, #38H
    ACALL WRITE_COM
; command #0EH belong to Display ON/OFF Command SET: #0000 1110B
;    - D on : Display ON
;    - U on : Cursor underline ON
;    - B off: Cursor blink off
    MOV A, #0EH
    ACALL WRITE_COM
; command #06H belong to Character Entry mode Command SET: #0000 0110B
;   - I/D : 1 = I so it will increment , means shift the pointer to next space
;   - S off: means that it will not shift the display frame when out of 16 char
    MOV A, #06H
    ACALL WRITE_COM
    POP ACC
    RET


WRITE_COM:
; this procedure will transfer a command to LCD, which is place in A-register
; this procedure won't change any register except : [DPTR] ; FOR SAFETY WE WILL PUSH POP DPH AND DPL
; to perform a command transfer successfully, we need:
;   - !!! prepare for A-register a command before call this procedure !!!
;   - LCD_RS at low (= 0 ) to tell LCD ready to get command info
;   - transfer command to LCD
;   - wait for LCD ready to process the command
;   - Keep LCD pin E enable during the above process
    PUSH DPH
    PUSH DPL
    MOV DPTR, #LCD_ADDRESS
    SETB LCD_E
    CLR LCD_RS
    MOVX @DPTR, A
    ACALL WAIT_LCD
    CLR LCD_E
    POP DPL
    POP DPH
    RET


WRITE_CHAR:
; this procedure will transfer a char to LCD ,  the char is placed in A-register
; this procedure won't change any register except : [DPTR] ; FOR SAFETY WE WILL PUSH POP DPH AND DPL
; to perform a charater transfer successfully, we need:
;   - !!! prepare for A-register a charater before call this procedure !!!
;   - LCD_RS at high (= 1 ) to tell LCD ready to get the char
;   - transfer char to LCD
;   - wait for LCD ready to store the char
;   - Keep LCD pin E enable during the above process
    PUSH DPH
    PUSH DPL
    MOV DPTR, #LCD_ADDRESS
    SETB LCD_E
    SETB LCD_RS
    MOVX @DPTR, A
    ACALL WAIT_LCD
    CLR LCD_E
    POP DPL
    POP DPH
    RET


WAIT_LCD:
; this procedure will delay a period of time equals to R7*R6*2 (micro-senconds)
; this will not affect any register
    PUSH 07
    PUSH 06
    MOV R6, #5
    WAIT_LOOP:
        MOV R7, #250
        DJNZ R7, $
    DJNZ R6, WAIT_LOOP
    POP 06
    POP 07
    RET

END