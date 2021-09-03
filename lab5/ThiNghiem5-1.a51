; ++++++++++++++++++++++++++++++++++++++++
; +      Nguyen Bui Nguyen Khoa, 2021    +
; +         nbnguyenkhoa@gmail.com       +
; +        nbnguyenkhoa.blogspot.com     +
; ++++++++++++++++++++++++++++++++++++++++
;
;   Lab 5
;   ThiNghiem1
; 
ORG 0000H
	LJMP MAIN
ORG 0023H
	LJMP SPI_ISR
MAIN:
	MOV TMOD,#20H
	MOV TH1,#-3
	SETB TR1
	MOV SCON,#01010010B
	MOV IE,#10010000B
	
LOOP:
	JB P1.0,ON
	CLR P1.1
	SJMP LOOP
ON: 
	SETB P1.1
	SJMP LOOP
	
	SJMP $
; END OF MAIN
; 
;
SPI_ISR:
	JBC TI, PHAT
	JBC RI, THU
	JMP EXIT
PHAT:
	JMP EXIT
THU:
	MOV A, SBUF
	MOV SBUF, A
EXIT:
	RETI
	
    END
