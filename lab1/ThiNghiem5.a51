; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 1
; Thi Nghiem 5
; 
; Request: create a simple LED effect on LED-bar
; 
		ORG 2000H
LAP:	LCALL EFF1
		SJMP LAP
		
EFF1:	MOV A,#01111111B
		MOV R1,#8
LAPE1:	MOV P1,A
		LCALL Delay1sIns
		RR A
		DJNZ R1, LAPE1
		RET

Delay1sIns:
		MOV R5, #2
LAPEX:	MOV R6, #250
LAPIN:	MOV R7, #250
		DJNZ R7,$
		DJNZ R6, LAPIN
		DJNZ R5, LAPEX
		RET

		END
; watch this effect by accesssing to the following link:
; https://i.ibb.co/S6VWd99/20210831-132741.gif