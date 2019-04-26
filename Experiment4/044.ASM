gewei EQU 37H
shiwei EQU 38H
Min_0 EQU 39H
Min_1 EQU 40H
Tem EQU 41H
diwei EQU 34H

ORG 0100H
TABLE:	
	DB 0C0h,0F9H,0A4H,0b0H,99H,92H,82H,0F8H,80H,90H,88H,83H,0C6H,0A1H,86H,8EH
 
DPDGLED:DB 040H,079H,024H,030H                     ;带小数点码表
        DB 19H,12H,02H,078H
	    DB 00H,10H,08H,03H
	    DB 46H,21H,06H,0EH

ORG 0000H
	LJMP M1

ORG 0200H
M1:	
	ACALL TEMREAD

	ACALL AUSZEIGEN

	ACALL DELAY
	ACALL DELAY
	ACALL DELAY

	AJMP M1					                       //LOOP

					
	   
TEMREAD:                                           //TEMREAD
    MOV DPTR,#0DFF8H			 
	MOVX @DPTR,A
	JB P3.3,$						   
	MOVX A,@DPTR

	MOV Tem,A					 

	ACALL XCHA
 
	RET
	
XCHA:				                               //数据处理
  	MOV A,Tem
  	MOV B,#50
  	MUL AB

	MOV diwei,A
	
	MOV A,B
	ADD A,#0

  	MOV B,#10
  	DIV AB
  	MOV gewei,B	                                  //个位

	MOV B,#10
  	DIV AB
  	MOV shiwei,B		                          //十位

    MOV A,diwei
	MOV B,#100
	MUL AB
	  
   	MOV B,#10
  	DIV AB
  	MOV Min_0,B	                                  //百分位

	MOV B,#10
  	DIV AB
  	MOV Min_1,B		                              //十分位

	RET


	
AUSZEIGEN:						
	MOV A,Min_1
	MOV DPTR,#TABLE
	MOVC A,@A+DPTR
	MOV DPTR,#7FF9H
	MOVX @DPTR,A

	MOV A,Min_0	
	MOV DPTR,#TABLE
	MOVC A,@A+DPTR
	MOV DPTR,#7FF8H
	MOVX @DPTR,A

	MOV A,shiwei
	MOV DPTR,#TABLE
	MOVC A,@A+DPTR
	MOV DPTR,#7FFBH
	MOVX @DPTR,A
	
	MOV A,gewei
	MOV DPTR,#DPDGLED
	MOVC A,@A+DPTR
	MOV DPTR,#7FFAH
	MOVX @DPTR,A	 

	RET

DELAY:
	MOV R3,#0FFH
DELAY1:
	MOV R4,#0FFH
	DJNZ R4,$
	DJNZ R3,DELAY1
	RET

END
