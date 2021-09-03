; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 3
; LCD.A51 with ADC accurate method
; 
; config some const 
LCD_E   BIT P3.3
LCD_RS  BIT P3.5
LCD_ADDRESS EQU 6000H
ADC_ADDRESS EQU 4000H
ORG 2000H
CONFIG:
    ACALL CLEAR_LCD
    ACALL INIT_LCD

MAIN:
    MOV R0, #0
    MOV R1, #0
    ACALL GOTOXY
    ACALL READ_ADC
    MOV R2, A       ; R2 will be the temp value to compare
    ACALL ADC_TO_SCREEN
    CHECK_CHANGE:
        ACALL READ_ADC ;  get a new of A value from ADC
        CJNE A, 02H , MAIN ; if A new not equal to R2 ( the old value), then update
        JMP CHECK_CHANGE   ; else check change again
    SJMP $

; END OF MAIN
; bundle of procedure
;
;
;
;---------------- 1# BUNDLE OF LCD------------------------
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
; --------------------- 2# BUNDLE OF ADC ----------------------
READ_ADC:
; this procedure will get data from ADC and store it to A
; only A is affected cuz it's the output of this procedure
    PUSH DPH
    PUSH DPL

    MOV DPTR, #ADC_ADDRESS
    MOV A, #0 ; choose the channel for ADC to start convert, we will choose chanel IN0 for our KIT
    MOVX @DPTR, A ; send choosing signal to ADC
    ACALL DELAY_ADC
    MOVX A, @DPTR ; get data from ADC after it has already done the converting proccess.

    POP DPH
    POP DPL

    RET

ADC_CALC:
; this procedure calculate the 8-bit data from ADC to float number. 
; 
; (ADC 8-bit) number to (X.YZ) float number
;
;  WHY WE FIRST DIVIDE A TO 51
;  BECAUSE WE HAVE THIS CONVERT FORMULAR
;
;                        5                          255
;       (ADC 8bit) * ----------- = (ADC 8bit) / ------------- = (ADC 8bit) / 51
;                        255                          5
;   Phan nguyen cua phep chia tren se la phan nguyen cua so thap phan, that means X
;   Phan du cua phep chia se co gia tri from 0 to 50
;   Convert phan du tro thanh phan thap phan (co 2 chu so) theo cong thuc:
;                   100           (a 16 bit number)
;   (Phan du) * ------------- = ----------------------     ( use 100 because need for 2 chu so thap phan nen * 10^2)
;                   51                  51
;
;
    PUSH B
    MOV B, #51 ; giai thich nhu tren
    DIV AB
    MOV R5, A ; R5 chua gia tri phan nguyen
    MOV A, B  ; chuyen han du ve lai cho A tiep tuc tinh toan
    MOV B, #100 ; Multiple 100 for B like the formula above
    MUL AB ; at here we will get a 16bit-number (B-A) , we need to perform (16bit)/51 like the second formula mentioned above.
    ACALL DIV16BY8
    MOV B, #10
    DIV AB
    MOV R6, A
    MOV R7, B
    POP B
    RET

DIV16BY8:
; this procedure will perform a divsion a 16 bit number by 51 for the convert formula used above
; this procedure will need an input: a 16 bit number stored in B and A. B is 8bit high order than A
; this procedure will make an output: A stored the result of the division (a 2 decimal number )
;
; this division is based on the algorithm that: 10 / 2
; 9 / 2 = >  9 - 2 = 7 > 0 ---> +1
;            7 - 2 = 5 > 0 ---> +1
;            5 - 2 = 3 > 0 ---> +1
;            3 - 2 = 1 > 0 ---> +1
;            1 - 2 = -1 < 0 ---> end ==> 4 
;           -1 + 2 = 1     ---> remainder is 1 
    PUSH 02
    PUSH 03
    PUSH 07

    MOV R2, B
    MOV R3, A
    MOV R7, #0 ; TEMP MEMORY FOR DIVISION RESULT   
    DIV_LOOP:
        CLR C
        MOV A, R3
        SUBB A, #51 ; cuz division by 51
        MOV R3, A
        MOV A, R2
        SUBB A, #0
        MOV R2, A
        JC KETTHUC_DIV
        INC R7
        SJMP DIV_LOOP
    KETTHUC_DIV:
        MOV A, R7

    POP 07
    POP 03
    POP 02

    RET

ADC_TO_SCREEN:
    ACALL ADC_CALC

    MOV A, R5
    ADD A, #30H
    ACALL WRITE_CHAR
    MOV A, #2EH ; 2EH = 46 IS A DOT
    ACALL WRITE_CHAR
    MOV A, R6
    ADD A, #30H
    ACALL WRITE_CHAR
    MOV A, R7
    ADD A, #30H
    ACALL WRITE_CHAR

    RET

DELAY_ADC:
; this procedure will wait for ADC a period of times to get the value
    PUSH 07
    MOV R7, #100
    DJNZ R7, $
    POP 07
    RET
END