; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 4
;   ThiNghiem2
; 
; Target: Create 1Hz Pulse on Pin P1.0 use mode 2 Timer 0 with XTAL = 11.059MHz
;         use DPTR 16-bit to count how many time timer has pass. If reach counter value, reverse the bit
ORG 2000H
	MOV TMOD, #02H
	MOV TH0, #-230
	MOV TL0, #-230
MAIN:
	CPL P1.0
	ACALL DELAY500MS
	SJMP MAIN
	SJMP $
;--------------------------------	
; XTAL = 11.059MHZ
DELAY500MS:
	PUSH DPH
	PUSH DPL
	LP:	SETB TR0
		JNB TF0, $
		CLR TR0
		CLR TF0
		INC DPTR
		MOV A, DPH
		CJNE A, #HIGH(2000), LP
		MOV A, DPL
		CJNE A, #LOW(2000), LP
	POP DPL
	POP DPH
	RET
	END