; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 4
;   ThiNghiem5
;   TARGET: sending charater to LCD display with some control function
;
; SHORT DESCRIPTION:
; this program will check if A is a letter from ASCII
;                           or A is a control character
; if A is a letter from ASCII, we simply do nothing, just increase the pointer by +1.
;          (if pointer > 16 then move to ROW 2, if pointer > 32, clear display and move to ROW 1 and continue the display)
;
; if A is a command key for controlling the display, then:
;   - a TAB key will be : CLEAR SCREEN and turn back pointer to 0.
;   - a Enter key will be: 
;               + if pointer in ROW 1 then move it to first place in ROW 2.
;               + if pointer in ROW 2 then clear screen and move it to first place in ROW 1.
;   - a BACKSPACE key will be:
;           + delete a character in the display, and reduce pointer by -1.
;           + if backspace is press at the first place of ROW2 and none character at there,
;                             then move pointer to ROW 1 and delete that following character.
;           + if backspace is press when there are no character on LCD, do nothing.
;
LCD_E	    BIT		P3.3
LCD_RS	    BIT 	P3.5
LCD_ADDRESS	    EQU		6000H
;
;	
ORG 2000H
; SET-UP TO READY FOR TRANSMITTING AND FOR LCD
; FIRST SET-UP FOR SMOD BIT = 1 ON PCON REGISTER => Speed up 9600 bps to 19200
	MOV A, PCON       
	SETB ACC.7
	MOV PCON, A
; SET-UP timer 1 mode 2 for generate baud rate right at 19200 bps ;
	MOV TMOD, #20H
	MOV TH1, #-3
	MOV TL1, #-3
	MOV SCON, #01010010B
	SETB TR1
; SETUP FOR LCD to be ready
	MOV DPTR,#LCD_ADDRESS
	LCALL CLEAR_LCD
	LCALL INIT_LCD
;
    MOV R7, #0 ; R7 will be the pointer move around same as the pointer in LCD display , at first we initialize it to be 0
;   
MAIN:
	CLR A                   ; delete A to get new charater
	LCALL IN_CHAR           ; get letter from terminal and stored it to A
	LCALL WRITE_CHAR        ; display the letter to the display on LCD
	LCALL OUT_CHAR          ; send back the letter to the terminal
    LCALL CONTROL_KEY_PROCEDURE ; a checking method to handle command key
	SJMP MAIN               ; loop back for new character

	SJMP $
; END OF MAIN
; SOME PROCEDURE FOR MAIN PROGRAM
;
; ************************************************
; *               SETTING FOR TX, RX             *
; *             SERIAL PORT'S PROCEDURE          *
; ************************************************
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
;
; ************************************************
; *          KEYBOARD CONTROL PROCEDURE          *
; ************************************************
;
CONTROL_KEY_PROCEDURE:
; this procedure will check if A is a letter from ASCII
;                           or A is a control character
; if A is a letter from ASCII, we simply do nothing, just increase the pointer by +1.
;          (if pointer > 16 then move to ROW 2, if pointer > 32, clear display and move to ROW 1)
;
; if A is a command key for controlling the display, then:
;   - a TAB key will be : CLEAR SCREEN and turn back pointer to 0.
;   - a Enter key will be: 
;               + if pointer in ROW 1 then move it to first place in ROW 2.
;               + if pointer in ROW 2 then clear screen and move it to first place in ROW 1.
;   - a BACKSPACE key will be:
;           + delete a character in the display, and reduce R0 by -1.
;           + if backspace is press at the first place of ROW2 and none character at there,
;                             then move pointer to ROW 1 and delete that following character.
;           + if backspace is press when there are no character on LCD, do nothing.
;
    CJNE A, #08H , NEXT_CHECKING_1 ; BACKSPACE = "08H" 
        ; if a BACKSPACE is press, do the BACKSPACE procedure,
        LCALL BACKSPACE
        JMP ALL_DONE
        ; IF NOT BACKSPACE move on to the next checking condition

    NEXT_CHECKING_1:
    CJNE A, #0DH , NEXT_CHECKING_2 ; ENTER = "0DH"
        ; if a ENTER is press, do the ENTER's jobs
		LCALL ENTER
		JMP ALL_DONE
        ; IF NOT ENTER move on to the next checking condition

    NEXT_CHECKING_2:
    CJNE A, #09H, END_OF_CHECKING; TAB KEY = "09H"
		LCALL TAB
        JMP ALL_DONE
        ; IF NOT TAB, that is the end of cheking, that just a normal character
    
    END_OF_CHECKING:
    ; if all the checking have pass, it means that A is just a character, we will handle character over here
    ; first let's increase pointer by 1 cuz it's a character
    INC R7
    ; then we will check if now the pointer have pass the limit of ROW 1
    CJNE R7, #16, TIEP_TUC_CHECK
        ; if it is true that is have pass the limit of ROW 1, MOVE it to line 2 , like this:
        MOV R0, #1 ; R0 IS FOR ROW
        MOV R1, #0 ; R1 IS FOR COLUMN
        LCALL GOTOXY
        JMP ALL_DONE
    ; so if A is not the limit of ROW 1, maybe it can be the limit of ROW 2, we will checking it by using this
    TIEP_TUC_CHECK:
    CJNE R7, #33, ALL_DONE
    ; if the letter is reach the limit of ROW 2, 
    ; then we will clear the screen, like a TAB key is press, so we can call TAB procedure for this
    ; and then send back the letter to the display, which is missing because of out of range
    LCALL TAB
    LCALL WRITE_CHAR
    ; else do nothing and return to MAIN program
    ALL_DONE:
    RET

;TAB PROCEDURE
TAB:
    LCALL CLEAR_LCD
    MOV R0, #0
    MOV R1, #0
    MOV R7, #0 ; ALSO set pointer = 0
    LCALL GOTOXY
    RET

;ENTER PROCEDURE
ENTER:
;   - a Enter key will be: 
;               + if pointer in ROW 1 then move it to first place in ROW 2.
;               + if pointer in ROW 2 then clear screen and move it to first place in ROW 1.
    CJNE R7, #16, $+3
    JC POINTER_IN_ROW_1

    POINTER_IN_ROW_2:
        LCALL TAB
        RET
    POINTER_IN_ROW_1:
        MOV R0,#1
        MOV R1,#0
        LCALL GOTOXY
        MOV R7, #16
        RET

; BACKSPACE PROCEDURE
BACKSPACE:
    ; check pointer = 0 or not
    ; if pointer = 0 , there are nothing to be deleted
    MOV A, R7
    JNZ HAVE_SOME_THING_TO_DELETE ; if pointer if not = 0 , we have something to do, so move on to delete function 
    ; else, ..... , do a blank screen and return to main, of course !!
    LCALL TAB ; do a blank screen is very important , because if we not do this, the pointer will move around, very uncomfortable
    RET

    HAVE_SOME_THING_TO_DELETE:
    DEC R7
    CJNE R7, #16, $+3      ; if counter > = 16 then it is at row 2 , so point it to row 2 proccess the delete function
    JC AT_ROW_1            ; else point it to ROW 1 function

    AT_ROW_2:
        ;move to the position we need to delete
        MOV R0, #1; SETUP FOR ROW 2
            MOV A, R7       ; 
            CLR C           ;   we need to get the right index of column in row 2,
            SUBB A, #16     ;   so we need subtract it to 16
        MOV R1, A
        LCALL GOTOXY
        ; when move to there, delete that character
        MOV A, #0
        LCALL WRITE_CHAR
        ; then move backward again, to waiting for next letter
        LCALL GOTOXY
        RET
    AT_ROW_1:
        ; move to the position we need to delete
        MOV R0, #0 ; SETUP ROW 1
        MOV R1, 07 ; 07 = R7, SETUP FOR COLUMN
        LCALL GOTOXY
        ; when move to there, delete that character
        MOV A, #0
        LCALL WRITE_CHAR
        ; then move backward again, to waiting for next letter
        LCALL GOTOXY
    RET
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
    LCALL WRITE_COM
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
    LCALL WRITE_COM
; command #0EH belong to Display ON/OFF Command SET: #0000 1110B
;    - D on : Display ON
;    - U on : Cursor underline ON
;    - B off: Cursor blink off
    MOV A, #0EH
    LCALL WRITE_COM
; command #06H belong to Character Entry mode Command SET: #0000 0110B
;   - I/D : 1 = I so it will increment , means shift the pointer to next space
;   - S off: means that it will not shift the display frame when out of 16 char
    MOV A, #06H
    LCALL WRITE_COM
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
    LCALL WAIT_LCD
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
    LCALL WAIT_LCD
    CLR LCD_E
    POP DPL
    POP DPH
    RET

GOTOXY:
; this procedure will goto round X, column Y
; data of X will be get from R0 ; R0 ~ [0,1] ; 0 for Row 1; 1 for Row 2
; data of Y will be get from R1 ; R1 ~ [0,15]
; 
; this procedure won't affect any register excpet [R0, R1] : those are input value
        PUSH ACC
		CJNE R0, #0, HANG_2
		HANG_1:
			MOV A, #80H ; start position of Row 1
			ADD A, R1
            JMP OK_GO_XY
		HANG_2:
			MOV A, #0C0H ; start position of Row 2
			ADD A, R1
        OK_GO_XY:
		LCALL WRITE_COM
        POP ACC
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