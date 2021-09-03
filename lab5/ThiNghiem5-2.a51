; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 5
;   ThiNghiem2
;
LEDBAR  EQU 0000H
ORG 0000H
LJMP MAIN
ORG 000BH
LJMP ISR_TIMER0
MAIN:
	MOV TMOD, #01H
	
	MOV R1, #1   ; config start LED at LED1 
    ; R1 store the position of LED, from 1 to 4
    ; R0 store the value of the display number, from 0 to 9
    
	MOV 20H, #5
	MOV 21H, #4
	MOV 22H, #3
	MOV 23H, #2
	
	SETB TF0
	MOV IE, #10000010B
	SJMP $
	
ISR_TIMER0:
	CLR TR0
	LCALL GET_DATA
	LCALL DISPLAY_LED
	;after done display the led, increase R1 to next LED
    INC R1
	CJNE R1, #5, NO_PROBLEM ; if R1 out of range [1,4] , then set it again to 1
	MOV R1, #1
	NO_PROBLEM: ; else if R1, still in range of [1,4] , restart the scanning timer
	MOV TH0, #HIGH(-9216)
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
	MOV A, @R0
	MOV R0, A
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
END