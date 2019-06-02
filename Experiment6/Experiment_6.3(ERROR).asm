  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H
			NUM1 EQU 33H
			NUM2 EQU 34H
			NUM3 EQU 35H
			NUM4 EQU 36H
			NUM_FLAG EQU 37H
			NUM_TOTAL EQU 38H
			SECOND_LOW EQU 40H
			SECOND_HIGH EQU 41H
			MINUTE_LOW EQU 42H
			MINUTE_HIGH EQU 43H

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

			MOV SECOND_LOW,#0H
			MOV SECOND_HIGH,#0H
			MOV MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H

			MOV WORD_CNT,#0H
			MOV NUM_FLAG,#0H
			MOV R1,#04H
			MOV R0,#33H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		
			AJMP SETDISPLAY
			AJMP DISPLAY			  ;�������ʾ
			MOV A,NUM_FLAG
			CJNE A,#1H,SKIP			  ;�����ֲ���4����ѭ��

			MOV NUM_FLAG,#0H			
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
			DJNZ R1,EXIT		   ;�ж��Ƿ���4�������룬û�����˳�
			MOV R0,#33H			   ;����R0��ֵ
			MOV R1,#04H			   ;����R7����
			MOV NUM_FLAG,#1H	   ;����־λ��1

EXIT:
			CLR RI
			SETB ES
			POP ACC
			POP PSW
			RETI	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;�������ʾ
DISPLAY:	;��һ�������
			MOV	DPTR,#DSEG1
			MOV  A,MINUTE_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H			     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;�ڶ��������
			MOV	DPTR,#DSEG1
			MOV A,MINUTE_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;�����������
			MOV	DPTR,#DSEG1
			MOV A,SECOND_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;���ĸ������
			MOV	DPTR,#DSEG1
			MOV A,SECOND_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF3H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			RET

SETDISPLAY:
			MOV A,#5FH
			DIV AB

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,59H,6EH,61H	 ; hina
		  DB 21H				 ; !

DSEG2:    DB 30H,31H,32H,33H
		  DB 34H,35H,36H,37H     ; 0-9
		  DB 38H,39H

DSEG3:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

			END