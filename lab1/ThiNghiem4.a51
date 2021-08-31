; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 1
; Thi Nghiem 4
; Request: create a procedure name Delay1sIns and use this procedure to blinking LED on P1.0 every 1 second.
; 1 second = 10^6 us
; each MC = 1us ; DJNZ consume 2MC => 2*250*260*8 = 10^6 us
;
		ORG 2000H
MAIN:	CPL P1.0
		LCALL Delay1sIns
		SJMP MAIN

Delay1sIns:
        MOV R5, #8
LAP1:   MOV R7, #250
LAP2:	MOV R7, #250
		DJNZ R7, $
        DJNZ R6, LAP2
        DJNZ R5, LAP1
		RET
		END