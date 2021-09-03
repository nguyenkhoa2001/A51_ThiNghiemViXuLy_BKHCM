; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 2
; Thi Nghiem 2
; 
; Request: make a program to display from 0 to 9 onto (0-place) 7-seg LED
;          for 1 second each time
;
	ORG 2000H
MAIN:
	MOV R0, #0
LP:
	ACALL DISPLAY_LED0
	ACALL Delay1sIns
	INC R0
	CJNE R0, #10, LP
	SJMP MAIN
	
DISPLAY_LED0:
	MOV A, R0
	ORL A, #0E0H    ; cuz 1110 xxxx will turn on the display of 0's 7-seg LED
	MOV DPTR, #0000H; address of 7-seg LED bar
	MOVX @DPTR, A   ; output to the 7seg LED
	RET

Delay1sIns:
		MOV R5, #8
LAPEX:	MOV R6, #250
LAPIN:	MOV R7, #250
		DJNZ R7,$
		DJNZ R6, LAPIN
		DJNZ R5, LAPEX
		RET

	END