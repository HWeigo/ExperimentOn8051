			MINUTE_HIGH EQU 30H
			MINUTE_LOW EQU 31H
			SECOND_HIGH EQU 32H
			SECOND_LOW EQU 33H 
			LETTER1 EQU 34H
			LETTER2 EQU 35H
			LETTER3 EQU 36H
			LETTER4 EQU 37H
			LETTERCNT EQU 38H
			ORG 0000H
			LJMP BEGIN
			ORG 0060H

BEGIN:
			MOV TMOD,#20H			;��ʱ��1ģʽ2����
			MOV TH1,#0FDH			;������9600
			MOV TL1,#0FDH			;������9600
			SETB TR1				;T1��ʼ����
			MOV SCON,#50H

MAIN:
			MOV MINUTE_HIGH,#00H
			MOV MINUTE_LOW,#00H
			MOV SECOND_HIGH,#00H
			MOV SECOND_LOW,#00H
			MOV LETTER1,#0H
			MOV LETTER2,#0H
			MOV LETTER3,#0H
			MOV LETTER4,#0H
			MOV LETTERCNT,#34H
NOTRECEIVE:
			JBC RI,L1				;�ж��Ƿ��д�����������
			LJMP NOTRECEIVE

RX:
			MOV A,SBUF				 ;���ܴ�������
			MOV @LETTERCNT,A		 ;�����ֽ�
			ANL A,#0FH				 ;�����λ
			MOV MINUTE_HIGH,A		 ;����λ�����Ĵ���
			MOV A,R1
			ANL A,#0F0H				 ;�����λ
			SWAP A					 ;�����ߵ�λ
			MOV MINUTE_LOW,A		 ;����λ�����Ĵ���
			ADD LETTERCNT			 ;�ֽڼ�����һ
			MOV A,LETTERCNT
			CJNE A,#39H,RX			 ;��δ��4λ�ֽ��������ȡ
			MOV LETTERCNT,#34H
			LCALL DISPLAY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADD1:
			MOV A,LETTER1
			MOV B,LETTER2
			CLR CY
			ADD A,B
			DA A				   ;�ֽ�ʮ�������
			MOV R5,A			   ;�洢�ۼ���
			MOV R6,#00H
			JNC ADD2			   ;���޽�λ����ת

			INC R6				   ;���н�λ���λ��һ

ADD2:
			MOV A,R5
			MOV B,R3
			CLR CY
			ADD A,B
			DA A				   ;�ֽ�ʮ�������
			MOV R5,A
			JNC ADD3

			INC R6

ADD3:
			MOV A,R5
			MOV B,R4
			CLR CY
			ADD A,B
			DA A				   ;�ֽ�ʮ�������
			MOV R5,A
			JNC TOTAL

			INC R6
			MOV A,R6
			MOV SECOND_HIGH,A

TOTAL:
			MOV A,R5
			ANL A,#0FH
			MOV MINUTE_HIGH,A
			MOV A,R5
			ANL A,#0F0H
			SWAP A
			MOV MINUTE_LOW,A
			LCALL DISPLAY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���ڷ���
SEND:

			MOV LETTERCNT,#39H
			MOV A,LETTERCNT
			MOV SBUF,A				   ;����ACC������
WAIT:		JNB TI,WAIT
			CLR TI					   ;TI����
			INC LETTERCNT			   ;ָ���ֽڼ�һ
			MOV A,LETTERCNT
			CJNE A,#H,SEND			   ;�ж��Ƿ�ȫ��������ϣ����޸�
			MOV LETTERCNT ,#34H		   ;�������������WORD_CNT
						
			LJMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�������ʾ
DISPLAY:	;��һ�������
			MOV	DPTR,#DSEG3
			MOV  A,MINUTE_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H			     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;�ڶ��������
			MOV	DPTR,#DSEG3
			MOV A,MINUTE_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;�����������
			MOV	DPTR,#DSEG3
			MOV A,SECOND_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;���ĸ������
			MOV	DPTR,#DSEG3
			MOV A,SECOND_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF3H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			RET					  

DELAY_SHORT:                   
           MOV R7,#10
DEL_SHORT: MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_SHORT
           RET

DELAY_LONG:                   
           MOV R7,#100
DEL_LONG:  MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_LONG
           RET

DSEG3:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,105,6EH,61H	 ; hina
		  DB 21H				 ; !

			END
