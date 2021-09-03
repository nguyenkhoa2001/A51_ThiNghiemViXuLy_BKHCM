; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 2
; Thi Nghiem 3
; 
; Request: make a program to display onto 7-seg LED the value of R0
;          the position of the 7-seg is determined by the value in R1
;          R0 = [0,...,9] ; R1 = [1,...,4]
;          set the number 1 display on the third LED
	ORG 2000H
MAIN:
	MOV R0, #1
    MOV R1, #3

	ACALL DISPLAY_LED
	SJMP $
	
DISPLAY_LED:
	MOV A, #11110111B
    CHOOSE_LED:
        RL A
        DJNZ R1, CHOOSE_LED ; Rotate A to get the right 7seg LED on
	ANL A, #0F0H
	ORL A, R0
	MOV DPTR, #0000H; address of 7-seg LED bar
	MOVX @DPTR, A   ; output to the 7seg LED
	RET

    END