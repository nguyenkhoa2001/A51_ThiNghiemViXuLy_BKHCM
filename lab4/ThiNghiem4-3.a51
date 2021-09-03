; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 4
;   ThiNghiem3
;   TARGET: post a string of "Hello world" to virtual terminal with baud rate of 19200bps everytime pin P1.0 is press
	ORG 2000H
; SET-UP TO READY FOR TRANSMITTING
; FIRST SET-UP FOR SMOD BIT = 1 ON PCON REGISTER
	MOV A, PCON       
	SETB ACC.7
	MOV PCON, A
; SET-UP timer 1 mode 2 for generate baud rate 19200 bps ; timer 0 mode 1 for delay function used later 
	MOV TMOD, #21H
	MOV TH1, #-3
	MOV TL1, #-3
	MOV SCON, #01000010B
	SETB TR1
	
MAIN:
	JB P1.0, $ ; wait for button P1.0 to be pressed
	ACALL DELAYBUTTON
    ; button press checking

    MOV DPTR, #TABLE ; pointing to the string
    SEND_LOOP:
        CLR A
	    MOVC A, @A+DPTR
	    ACALL OUT_CHAR
	    INC DPTR
	CJNE A, #0, SEND_LOOP ; if scan to the end letter \0, then stop sending and loop back the main to check button P1.0
	SJMP MAIN

;
;   END of main
;   below are procedure 
;
OUT_CHAR:
	JNB TI, $
	CLR TI
	MOV SBUF, A
	RET
	
DELAYBUTTON:
	PUSH 07
	MOV R7, #5
	TIMER_LOOP:
		MOV TH0, #HIGH(-50000)
		MOV TL0, #LOW(-50000)
        SETB TR0
        JNB TF0, $
        CLR TR0
        CLR TF0
	DJNZ R7, TIMER_LOOP
	POP 07
	RET

TABLE: DB "Hello, World!",0

	END