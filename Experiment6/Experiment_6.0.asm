  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			;ORG 0023H
			;AJMP UARTINT
			ORG 0060H

START:	 	MOV SP,#5FH
			MOV TMOD,#21H	;��ʱ��1ģʽ2���������ڿ��Ʋ�����; ��ʱ��0����3s��ʱ
			MOV PCON,#00H 	;����Ƶ
			MOV TH1,#0FDH	;������9600
			MOV TL1,#0FDH	;������9600
			MOV SCON, #50H ;���ڹ�����ʽ1
			MOV TH0,#4CH   ;��ʱ50ms
   			MOV TL0,#00H   ;��ʱ50ms
			
			SETB REN	 	;�������
			SETB TR1		;T1��ʼ����
			SETB PS 		;���ô������ȼ�Ϊ��
			SETB ES			;ʹ�ܴ����ж�
			SETB ET0		;ʹ�ܶ�ʱ��0�ж�
			SETB EA			;ʹ�������ж�

			MOV WORD_CNT,#1H

LOOP:		MOV A,TIME_FLAG
			CJNE A,#1H,SKIP

SEND:		MOV	DPTR,#DSEG1			   ;DSEG1�д�ŷ������ݵ�ASCII��
			MOV  A, WORD_CNT
			MOVC	A,@A+DPTR
			MOV SBUF,A
			JNB TI,$
			CLR TI
			INC WORD_CNT
			MOV A,WORD_CNT
			CJNE A,#5H,SEND				;���޸�
			MOV WORD_CNT ,#1H
			 
SKIP:		SJMP LOOP


;��ʱ���ж�
TIMINT:		MOV TH0,#4CH	 	;���ó�ֵ
			MOV TL0,#0H

			INC TCOUNT
			MOV A,TCOUNT
			CJNE A,#60,NEXT_TINT	;50ms����Ϊ��60�Σ���3s������
			MOV TCOUNT,#0H		 	;����50ms������TCOUNT
			MOV TIME_FLAG,#1H	 	;��3s��ʱflagΪ1

NEXT_TINT:
			RETI

DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,59H,6EH,61H	 ; hina
		  DB 21H				 ; !

			END