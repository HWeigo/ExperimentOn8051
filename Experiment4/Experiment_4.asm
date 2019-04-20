		    TEMPERATURE_HIGH EQU 30H
			TEMPERATURE_LOW EQU	31H
			COUNT EQU 32H

			ORG 0H
			AJMP MAIN
			ORG 0013H
			AJMP INT1
			ORG 000BH
			AJMP TINT0

			ORG 60H
MAIN:		;��ʼ��
			MOV TEMPERATURE_HIGH,0H
			MOV TEMPERATURE_LOW,0H
			MOV 
			
			SETB EA			;CPU�����ж�
			
			;�ⲿ�жϳ�ʼ��
			SETB IT1		;�����ⲿ�жϴ�����ʽ-�½��ش���
			SETB PX1		;����INT1�����ȼ�
			SETB EX1		;�����ж�

			MOV DPTR,#7FF8H	;ָ��IN0
			MOVX @DPTR,A	;����ADת��

LOOP:		ACALL DISPLAY
			SJMP LOOP					


			ORG 0200H
INT1:		
			PUSH PSW		;���溯��ָ��
			PUSH ACC 		;����Ĵ���
			
			
			MOVX A,@DPTR	;����ADת��
			MOV @R0,A


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

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  