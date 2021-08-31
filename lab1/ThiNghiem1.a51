; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
; Lab 1
; Thi nghiem 1
; Read the state of button P1.0 and display it on LED P3.0
;
		ORG 2000H
MAIN:	MOV C,P1.0
		MOV P3.0, C
		SJMP MAIN
		END