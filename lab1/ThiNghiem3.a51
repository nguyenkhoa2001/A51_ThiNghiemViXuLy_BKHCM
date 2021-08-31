; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 1
; TN 3
; Request: create 1kHz pulse with Duty Cycle = 50% on pin P3.0
; 1kHz pluse ==> each High Pluse = each Low Pulse = 500us ~= 500 MCs (XTAL ~= 12Mhz)
; DJNZ consume 2MCs, so we set Rx = 500/2 = 250
;
		ORG 2000H
MAIN:	CPL P3.0
		LCALL DELAY
		SJMP MAIN

DELAY:
		MOV R7, #250 ; set 230 with XTAL = 11.059MHz for more precisely frequency
		DJNZ R7, $
		RET
		END