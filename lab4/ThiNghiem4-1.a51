; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 4
;   ThiNghiem1
; 
; Target: Create 1Hz Pulse on Pin P1.0 use mode 1 Timer 0 with XTAL = 11.059MHz
	ORG 2000H
	MOV TMOD, #01H
	
MAIN:
	CPL P1.0
	ACALL DELAY500MS
	SJMP MAIN
	SJMP $
;--------------------------------	
; XTAL = 11.059MHZ
DELAY500MS:
	PUSH 07         ; 500ms = 50 000(us) * 10 
	MOV R7, #9      ; because of XTAL = 11.029MHz so it decrease to 9 for more precision
	LP:	MOV TH0, #HIGH(-50000)      ; best precision number(s) are: Tx = -49079 and R7 = 10
		MOV TL0, #LOW(-50000)       ; or Tx = -51199 and R7 = 9
		SETB TR0
		JNB TF0, $
		CLR TR0
		CLR TF0
	DJNZ R7, LP
	POP 07
	RET
	END