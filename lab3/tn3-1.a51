; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 3
; ThiNghiem1
; 
; config some const 
LCD_E   BIT P3.3
LCD_RS  BIT P3.5
LCD_ADDRESS EQU 6000H

ORG 2000H
MAIN:
    ACALL CLEAR_LCD
    ACALL INIT_LCD

    MOV DPTR, #MESSAGE
    ACALL DISPLAY_STRING

    SJMP $


; END OF MAIN
; bundle of procedure
;
;
;

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
; this procedure will transfer a char to LCD, the char is placed in A-register
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

DISPLAY_STRING:
; this procedure will display a text string start at DPTR and will end at exit char \0
; for this procedure to perform as intended, it needs::
;  - set DPTR at the message string !!!BEFORE!!! calling this procedure
; this procedure won't affect ANY register , except DPTR as an input
    PUSH ACC
    STRING_LOOP:
        MOV A, #0               ;delete A for new charatec index with [A+DPTR]
        MOVC A, @A+DPTR
        JZ EXIT_STRING          ;if A = exit letter \0 then exit this string loop
        ACALL WRITE_CHAR        ;else write the letter in A onto LCD 
    INC DPTR                    ; move the index to the next letter
    JMP STRING_LOOP
    EXIT_STRING:
    POP ACC
    RET

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

MESSAGE:
    DB "HELLO WORLD!",0

END