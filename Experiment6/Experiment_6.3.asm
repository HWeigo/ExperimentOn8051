  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H
			NUM1 EQU 33H
			NUM2 EQU 34H
			NUM3 EQU 35H
			NUM4 EQU 36H
			NUM_FLAG EQU 37H
			NUM_TOTAL EQU 38H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			ORG 0023H
			AJMP UARTINT
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

			MOV WORD_CNT,#0H
			MOV NUM_FLAG,#0H
			MOV R7,#04H
			MOV R0,#33H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		
			MOV A,NUM_FLAG
			CJNE A,#1H,SKIP			  ;�����ֲ���4����ѭ��

			MOV A,#0H
			ADD A,NUM1
			ADD A,NUM2
			ADD A,NUM3
			ADD A,NUM4				  ;�ۼ�
			MOV NUM_TOTAL,A 

SEND:		
			MOV SBUF,A				   ;����ACC������
			JNB TI,$				   ;�ȴ�������ϣ�TI=1)
			CLR TI					   ;TI����
			 
SKIP:		SJMP LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�����ж�
UARTINT:	
			PUSH PSW
			PUSH ACC			   ;�ֳ�����
			CLR ES				   ;�رմ����ж�
							  

			MOV A,SBUF			   ;�����ڶ�ȡ�����Ĵ���A
			MOV @R0,A			   ;��A����R0ָ���ַ��R0->33H,34H,35H,36H)
			INC R0				   ;R0��һ
			DJNZ R7,EXIT		   ;�ж��Ƿ���4�������룬û�����˳�
			MOV R0,#33H			   ;����R0��ֵ
			MOV R7,#04H			   ;����R7����
			MOV NUM_FLAG,#1H	   ;����־λ��1

EXIT:
			CLR RI
			SETB ES
			POP ACC
			POP PSW
			RETI	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,59H,6EH,61H	 ; hina
		  DB 21H				 ; !

DSEG2:    DB 30H,31H,32H,33H
		  DB 34H,35H,36H,37H     ; 0-9
		  DB 38H,39H

			END