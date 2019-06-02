  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H
			SECOND_LOW EQU 40H
			SECOND_HIGH EQU 41H
			MINUTE_LOW EQU 42H
			MINUTE_HIGH EQU 43H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			;ORG 0023H
			;AJMP UARTINT
			ORG 0060H

START:	 	MOV SP,#0060H
			MOV SCON,#40H	;���ô���Ϊģʽ1����
			MOV PCON,#00H 	;����Ƶ
			MOV TMOD,#21H	;��ʱ��1ģʽ2���������ڿ��Ʋ�����; ��ʱ��0����3s��ʱ
			MOV TH1,#0FDH	;������9600
			MOV TL1,#0FDH	;������9600
			MOV TH0,#4CH    ;��ʱ50ms
   			MOV TL0,#00H    ;��ʱ50ms

			SETB REN	 	;�������
			SETB TR1		;T1��ʼ����
			SETB TR0
			SETB ET0		;ʹ�ܶ�ʱ��0�ж�
			SETB EA			;ʹ�������ж�

			MOV TIME_FLAG,#0H
			MOV WORD_CNT,#1H
			MOV SECOND_LOW,#1H
			MOV SECOND_HIGH,#0H
			MOV MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		
			MOV A,30H
			CJNE A,#1H,SKIP			   ;����Ƿ�ﵽ3s��ʱ

SEND:		
			MOV 30H,#0H
            MOV	DPTR,#DSEG1			   ;DSEG1�д�ŷ������ݵ�ASCII��
			MOV A, WORD_CNT
			MOVC A,@A+DPTR		   ;��WOED_CNT���ֽڶ�Ӧ��ASCII�����ACC
			MOV SBUF,A				   ;����ACC������
WAIT:		JNB TI,WAIT
			CLR TI					   ;TI����
			INC WORD_CNT			   ;ָ���ֽڼ�һ
			MOV A,WORD_CNT
			CJNE A,#10H,SEND			   ;�ж��Ƿ�ȫ��������ϣ����޸�
			MOV WORD_CNT ,#0H		   ;�������������WORD_CNT
			 
SKIP:		SJMP LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ʱ���ж�
TIMINT:		
			PUSH ACC
			MOV TH0,#4CH	 	;���ó�ֵ
			MOV TL0,#0H

			INC 31H
			MOV A,31H
			CJNE A,#20,NEXT_TINT	;50ms����Ϊ��60�Σ���3s������
			MOV 31H,#0H		 	    ;����50ms������TCOUNT
			MOV 30H,#1H	        	;��3s��ʱflagΪ1
			INC MINUTE_LOW

NEXT_TINT:
			POP ACC
			RETI

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