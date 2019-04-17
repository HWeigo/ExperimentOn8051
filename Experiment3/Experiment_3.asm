  		    SECOND_LOW EQU 30H
			SECOND_HIGH EQU 31H
			MINUTE_LOW EQU 32H
			MINUTE_HIGH EQU 33H
			FLAG EQU R3
						
  		    ORG 0H
			AJMP MAIN		
			ORG 000BH
			AJMP TINT0

			ORG  60H
MAIN:		
			;��ʼ��
			MOV	30H,#0H
			MOV 31H,#0H
			MOV	32H,#0H
			MOV 33H,#0H
			MOV 34H,#0H
			MOV FLAG,#0H

			;��ʱ���ж�ʹ��
			MOV TMOD,#01H 		;t0ʹ��ģʽ1��ʱ��
			MOV TH0,#04CH	 		;���ö�ʱ50ms
			MOV TL0,#0H
			SETB ET0		 	;t1�����ж�
			SETB TR0 			;������ʱ
			
			
LOOP:	  	;�������ʾ
			JNB P1.0,CLEAR
			JNB P1.1,STOP
			JNB P1.2,START
			ACALL DISPLAY

			SJMP LOOP
			

CLEAR:		MOV TMOD,#01H 		;t0ʹ��ģʽ1��ʱ��
			MOV TH0,#04CH	 		;���ö�ʱ50ms
			MOV	30H,#0H
			MOV 31H,#0H
			MOV	32H,#0H
			MOV 33H,#0H
			MOV 34H,#0H
			LJMP LOOP
			RET

STOP:		CLR ET0
			LJMP LOOP
			RET

START:		SETB ET0
			LJMP LOOP
			RET

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ʱINC�Ĵ���
			
TINT0:		MOV TH0,#04CH	 	;���ó�ֵ
			MOV TL0,#0H

			;MOV A,FLAG
			;CJNE A,#0H,NEXT_TINT

			INC 34H
			MOV A,34H
			CJNE A,#20,NEXT_TINT	;50ms����Ϊ��20�Σ�����
			MOV 34H,#0H
			INC 30H
			MOV A,30H
			CJNE A,#5H,NEXT_TINT
			MOV 30H,#0H
			INC 31H
			MOV A,31H
			CJNE A,#3H,NEXT_TINT
			MOV 31H,#0H
			INC 32H
			MOV A,32H
			CJNE A,#10,NEXT_TINT			 
			MOV 32H,#0H
			INC 33H
			MOV A,33H
			CJNE A,#6H,NEXT_TINT
			MOV 33H,0H
						
NEXT_TINT:			
			RETI

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
DISPLAY:	;��һ�������
			MOV	DPTR,#DSEG1
			MOV  A,30H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H		     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;�ڶ��������
			MOV	DPTR,#DSEG1
			MOV A,31H
			MOVC	A,@A+DPTR
		
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;�����������
			MOV	DPTR,#DSEG1
			MOV A,32H
			MOVC	A,@A+DPTR
				CLR ACC.7
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;���ĸ������
			MOV	DPTR,#DSEG1
			MOV A,33H
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
           MOV R7,#250
DEL_LONG:  MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_LONG
           RET

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        ;��y??1������??����
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  ;3��D��?����?