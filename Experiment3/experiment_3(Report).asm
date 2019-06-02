  		    SECOND_LOW EQU 30H
			SECOND_HIGH EQU 31H
			MINUTE_LOW EQU 32H
			MINUTE_HIGH EQU 33H
			TCOUNT EQU 34H
						
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
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main����			
LOOP:	  	;�������
			JNB P1.0,CLEAR
			JNB P1.1,STOP
			JNB P1.2,START
			ACALL DISPLAY

			SJMP LOOP			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;����
CLEAR:			 		
			MOV	SECOND_LOW,#0H
			MOV SECOND_HIGH,#0H
			MOV	MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			MOV TCOUNT,#0H
			LJMP LOOP
			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ͣ�����
STOP:		CLR ET0
			LJMP LOOP
			;RET

START:		SETB ET0
			LJMP LOOP
			;RET

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ʱINC�Ĵ���
			
TINT0:		MOV TH0,#04CH	 	;���ó�ֵ
			MOV TL0,#0H

			INC TCOUNT
			MOV A,TCOUNT
			CJNE A,#20,NEXT_TINT	;50ms����Ϊ��20�Σ�����
			MOV TCOUNT,#0H		 	;����50ms������TCOUNT
			INC SECOND_LOW			;���λ����1
			MOV A,SECOND_LOW
			CJNE A,#10,NEXT_TINT	;���λδ��10������
			MOV SECOND_LOW,#0H		;�������λ
			INC SECOND_HIGH			;��ʮλ��1
			MOV A,SECOND_HIGH
			CJNE A,#6,NEXT_TINT		;��ʮλδ��6������
			MOV SECOND_HIGH,#0H		;������ʮλ
			INC MINUTE_LOW			;�ָ�λ��1
			MOV A,MINUTE_LOW
			CJNE A,#10,NEXT_TINT	;�ָ�λδ��10������
			MOV MINUTE_LOW,#0H		;���÷ָ�λ
			INC MINUTE_HIGH			;��ʮλ��1
			MOV A,MINUTE_HIGH
			CJNE A,#6,NEXT_TINT	;��ʮλδ��6������
			MOV MINUTE_HIGH,#0H		;���÷ָ�λ
						
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
			CLR ACC.7				 	;����С����λ
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

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  