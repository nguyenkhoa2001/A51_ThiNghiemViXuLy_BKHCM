; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 5
;   ThiNghiem4
;
LEDBAR  EQU 0000H

ORG 0000H
LJMP MAIN

ORG 000BH
LJMP ISR_TIMER0

MAIN:
	MOV TMOD, #01H
	
	RESET:
	MOV R1, #1   ; config start LED at LED1 
    ; R1 store the position of LED, from 1 to 4
    ; R0 store the value of the display number, from 0 to 9

	MOV 20H, #0		;	20H and 21H store the value of second unit, range 0~59
	MOV 21H, #0		;	so that 20h ~ [0,5] and 21H ~ [0,9]
	MOV 22H, #0		;	22H, 23H stored the percent of second 's value , range 0~99
	MOV 23H, #0		;	so that 22H ~ [0,9] and 23H ~ [0,9]
	
	SETB F0 ; a flag that indicate the program do or dont update the value in memory place
	; F0 = 1 : do not update value
	; F0 = 0 : update value
	; the implement of this flat is in UPDATE_VALUE procedure
	MOV IE, #10000010B	; allow for timer0 interrupt

    CHECKING_LOOP:
		MOV R7, #255		; debouncing for the buttons for safety
		DJNZ R7, $			; polling check for 3 button
		JNB P1.0, RESET		; checking reset button
		JNB P1.1, START		; checking start button
		JNB P1.2, STOP		; checking stop button
		JMP CHECKING_LOOP
		
	START:
	; if start button is press
	; it will allow memory [20H,21H,22H,23H] to be updated the value by turn off F0 flag
	; then it will will start the timer by setb TF0
	; and then it will go back and cheking the polling button loop
		CLR F0
		SETB TR0
		JMP CHECKING_LOOP
	
	STOP:
	; if stop button is press
	; it will allow memory [20H,21H,22H,23H] to stop update the value by turn on F0 flag
	; and then it will go back and cheking the polling button loop
		SETB F0
        JMP CHECKING_LOOP
		
	SJMP $
	
ISR_TIMER0:
	CLR TR0
	LCALL GET_DATA
	LCALL DISPLAY_LED
	;after done display the led, increase R1 to next LED
    INC R1
	CJNE R1, #5, NO_PROBLEM ; if R1 out of range [1,4] , then set it again to 1
	MOV R1, #1
	NO_PROBLEM: ; else if R1 still in range of [1,4] , update the new value of time and restart the scanning timer
	LCALL UPDATE_VALUE
	MOV TH0, #HIGH(-9216) ; 9216 MCs = 9216 * 1.085us ~= 10ms
	MOV TL0, #LOW(-9216)
	SETB TR0
	RETI

GET_DATA:
	MOV A, #24H ; because 20H is thousand , 21H is hundred , 22H is 10-line, and 23 is unit line
    ; so if R1 = 1, means LED 1 at unit-line, then we need to take the value of 23H
    ; that is 24H - 1 = 23H
    ; what about R1 = 2 , then we need to take 10-line, means 22H
    ; that is 24H - 2 = 22H
    ; and so on, so here are the algorithm
	CLR C
	SUBB A, R1
	MOV R0, A
	MOV A, @R0 ; pointing to [20H or 21H  or ...] memory
	MOV R0, A  ; R0 stored the value of LED in range [0,9]
	RET
	
DISPLAY_LED:
	PUSH 01
	MOV A, #11110111B
    CHOOSE_LED:
        RL A
        DJNZ R1, CHOOSE_LED ; Rotate A to get the right 7seg LED on
	ANL A, #0F0H
	ORL A, R0
	MOV DPTR, #LEDBAR; address of 7-seg LED bar
	MOVX @DPTR, A   ; output to the 7seg LED
	POP 01
	RET

UPDATE_VALUE:
		JB F0, UPDATED
        INC 23H
		MOV A, 23H
        CJNE A, #10, UPDATED
        
        MOV 23H, #0
        INC 22H
		MOV A, 22H
        CJNE A, #10, UPDATED

        MOV 22H, #0
        INC 21H
		MOV A, 21H
        CJNE A, #10, UPDATED

        MOV 21H, #0
        INC 20H
		MOV A, 20H
        CJNE A, #6, UPDATED
        MOV 20H, #0
	UPDATED:
	RET
END
