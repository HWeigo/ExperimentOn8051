			ORG 0000H
			AJMP MAIN		
			ORG 0003H
			AJMP PINT0
					
			ORG  0100H
MAIN:		
            ;��ʼ��
			MOV	30H,#0H
			MOV 31H,#0H
			MOV	32H,#0H
			MOV 33H,#0H

			MOV R0,#40H						 ;���������׵�ַ
			MOV R2,#01H						 ;�ܲ�ѯͨ����
			SETB IT0						 ;���ж�				   				;Ӧʹ���ж�ԴINT0?��8090EOC��INT1)
			SETB EA
			SETB EX0
			;��һ�ο���ADת��
			MOV DPTR, #0DFF9H				 ;A13=0,��ָ��IN0ͨ��		 			 ;Ӧ����0DFF8H?(ͨ��0��
			MOVX @DPTR,A					 ;����ADת��
LOOP:
            MOV A,40H						 ;A����8λADC���,��������ͨ��IN0
			MOV B,#100
			DIV AB
			MOV 30H,A						 										;��λ�ŵ���һ�������				   ����ʮ��λ�ŷ��˰�
			MOV A,B																	;������ֵ��A
			MOV B,#10																
			DIV AB
			MOV 31H,A																;ʮλ�ŵ��ڶ��������
			MOV 32H,B																;��λ�ŵ���һ�������
						
			ACALL DISPLAY					 ;ˢ�������
			SJMP LOOP						 ;��ѭ�����ȴ��ж�

			ORG 0200H
PINT0:		
            PUSH PSW
            PUSH ACC
			;PUSH R3                          ;��֪����û�б�Ҫ						   �������ط�û�õ�R3	�ҹ����Ĵ������ܽ�ջ ������ERROR
			MOV DPTR, #0DFF9H				 ;ָ���һͨ��		 					  ;Ӧ����0DFF8H?(ͨ��0��
			MOVX A,@DPTR					 ;ת������������ת�����
			MOV @R0,A						 ;�����ڲ�RAM�洢��
			INC R0																	   ;û����ΪʲôҪ��һR0
			INC DPTR
			DJNZ R2,NEXT
			CLR EX0																	 ;ΪʲôҪ�ر��ж�ʹ�ܣ�	��R2û�����¸�ֵ
			SJMP DONE
NEXT:       MOVX @DPTR,A					 ;�ٴ�����������ת����R2��ͨ��
            ;POP R3
            POP ACC
			POP PSW
DONE:       MOV DPTR, #0DFF9H				 ;ָ���һͨ��
            MOVX @DPTR,A					 ;�ٴ���������һ���¶�ˢ��
            RETI


;***********�����ˢ��*************;
DISPLAY:	
            ;��һλ
			MOV	DPTR,#DSEG1
			MOV  A,30H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H		     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;�ڶ�λ
			MOV	DPTR,#DSEG1
			MOV A,31H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;����λ
			MOV	DPTR,#DSEG1
			MOV A,32H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;����λ
			MOV	DPTR,#DSEG1
			MOV A,33H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF3H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			RET

DELAY_SHORT:                      ;�ӳ�
           MOV R7,#10
DEL_SHORT: MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_SHORT
           RET

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H  ;����
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH


          END                  