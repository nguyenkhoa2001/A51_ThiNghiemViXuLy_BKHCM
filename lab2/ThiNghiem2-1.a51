; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 2
; Thi Nghiem 1
; 
; Request: create a procedure to display the value of R0 onto (0-place) 7-seg LED
;           use that procedure in main to display number '9' onto the "0-place" 7-seg LED
;
	ORG 2000H
MAIN:
	MOV R0, #9
	ACALL DISPLAY_LED0
	SJMP $
	
DISPLAY_LED0:
	MOV A, R0
	ORL A, #0E0H    ; cuz 1110 xxxx will turn on the display of 0's 7-seg LED
	MOV DPTR, #0000H; address of 7-seg LED bar
	MOVX @DPTR, A   ; output to the 7seg LED
	RET

	END