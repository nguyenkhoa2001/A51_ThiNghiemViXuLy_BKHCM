; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 2
; Thi Nghiem 4
; 
; Target: make a program to display a 24h clock on 4 7-seg LED
; 
; Describe program:
;   24H memory place store counter for 24h
;   R3 ~ for LED 4, so it would be # 0111 xxxx B or #7xH 
;   R2 ~ for LED 3, so it would be # 1011 xxxx B or #0BxH 
;   R1 ~ for LED 2, so it would be # 1101 xxxx B or #0DxH 
;   R0 ~ for LED 1, so it would be # 1110 xxxx B or #0ExH 
;   
;   so the display will be    hh  :  mm     [hh=hours, mm= minutes]
;                           R3-R2 : R1-R0
;   R3: the ten-floor of hh number, R3 = [0,1,2]
;   R2: the unit-floor of hh number, R2 = [0,...,9]
;   R1: the ten-floor of mm number , R1 = [0,...,5] as for 0s to 59 second
;   R0: the unit-floor of mm number , R0 = [0,...9]
;
;   The loop in the program will scan all the LED with high speed, so we can't use a Delay function to create 1 second timer
;   So with that delay in the program, it will destroy the LED scanning effect
;   So an alternative solution is that we will make use of the Delay timing between each LED, 
;   and adjust how many loop the same frame with R7. More R7 mean more time for each frame, and scale it to reach 1 second delay
ORG 2000H
		MOV DPTR, #0000H
MAIN:
		MOV 24H, #24
		MOV R3, #70H
LP4:	MOV R2, #0B0H
LP3:	MOV R1, #0D0H
LP2:	MOV R0, #0E0H

LP1:	MOV R7, #50
LAP:	LCALL LED0
		LCALL DELAY
		LCALL LED1
		LCALL DELAY
		LCALL LED2
		LCALL DELAY
		LCALL LED3
		LCALL DELAY
		DJNZ R7, LAP
		
		INC R0
		CJNE R0, #0EAH, LP1 ; R0 reach 10, that is out of range of R0, so increse R1, and turn R0 to 0
		
		INC R1
		CJNE R1, #0D6H, LP2 ; R1 reach 6, that is out of range of R1, so increse R2, and turn R1 to 0

		INC R2
		DJNZ 24H, HERE ; each time R2 INC mean that 1h has passed, so decrease 24H memory to ensure that it will turn to 0 again after 24h have passed
		SJMP MAIN
		
HERE:	CJNE R2, #0BAH, LP3 ; R2 reach 10, means that out of range of R2, so + 1 for R3 and turn R2 to 0
		
		INC R3
		SJMP LP4

; each LEDx procedure handle a LED display 
LED0:
	MOV A, R0
	MOVX @DPTR, A
	RET
LED1:
	MOV A, R1
	MOVX @DPTR, A
	RET
LED2:
	MOV A, R2
	MOVX @DPTR, A
	RET
LED3:
	MOV A, R3
	MOVX @DPTR, A
	RET
	
DELAY:
		PUSH 07H
		PUSH 06H
		MOV R6, #20
TIME:	MOV R7, #50
		DJNZ R7, $
		DJNZ R6, TIME
		POP 06H
		POP 07H
		RET
		END