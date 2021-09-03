; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 2
; Thi Nghiem 4
; 
; Target: make a program to display as following description:
;          - number 1 display on 7segLED 1 in 1 second then
;          - number 2 display on 7segLED 2 in 1 second then
;          - number 3 display on 7segLED 3 in 1 second then
;          - number 4 display on 7segLED 4 in 1 second then loop all
; reduce 1 second to some smaller times and watch LED scanning effect
	ORG 2000H
MAIN:
	MOV R0, #1	; R0 STORE VALUE
    MOV R1, #1	; R1 STORE POSITION
    LP:
	ACALL DISPLAY_LED
    ACALL Delay
    INC R0
    INC R1
    CJNE R0, #5, LP
	SJMP MAIN
	
DISPLAY_LED:
	PUSH 00
	PUSH 01
	MOV A, #11110111B
    CHOOSE_LED:
        RL A
        DJNZ R1, CHOOSE_LED ; Rotate A to get the right 7seg LED on
	ANL A, #0F0H
	ORL A, R0
	MOV DPTR, #0000H; address of 7-seg LED bar
	MOVX @DPTR, A   ; output to the 7seg LED
	POP 01
	POP 00
	RET

Delay:
		MOV R5, #8
LAPEX:	MOV R6, #250
LAPIN:	MOV R7, #250
		DJNZ R7,$
		DJNZ R6, LAPIN
		DJNZ R5, LAPEX
		RET
    END