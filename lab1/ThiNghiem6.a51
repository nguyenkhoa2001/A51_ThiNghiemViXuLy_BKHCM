; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 1
; Thi Nghiem 5
; 
; Request: create multiple LED effect on LED-bar
; 
		ORG 2000H
LAP:	LCALL EFF1
		LCALL EFF2
		LCALL EFF3
		SJMP LAP
		
EFF1:	MOV A,#01111111B
		MOV R1,#8
LAPE1:	MOV P1,A
		LCALL Delay1sIns
		RR A
		DJNZ R1, LAPE1
		RET
		
EFF2:	MOV A,#01010101B
		MOV R1,#2
LAPE2:	MOV P1,A
		LCALL Delay1sIns
		RR A
		DJNZ R1, LAPE2
		RET

EFF3:	MOV A,#11111110B
		MOV R1,#7
LAPE3:	MOV P1,A
		LCALL Delay1sIns
		RL A
		DJNZ R1, LAPE3
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
; https://i.ibb.co/Hxz46nm/tn6-multiple-Effect.gif