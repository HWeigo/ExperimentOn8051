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
			MOV R2,#01H						 ;�ܲ�ѯͨ�����������ͨ����
			SETB IT1						 ;���ж�                                 ;Ӧʹ���ж�ԴINT0?��8090EOC��INT1)
			SETB EA
			SETB EX0
			;��һ�ο���ADת��
			MOV DPTR, #0DFF8H				 ;A13=0,��ָ��IN0ͨ��		 			 ;Ӧ����0DFF8H?(ͨ��0��
			MOVX @DPTR,A					 ;����ADת��
LOOP:
			MOV A,40H     ;����IN0���ÿ����¶�
			MOV R1,#32H   ;�����¶�С��������ʮ������30H,31H,32H��R1���ADC������������
			ACALL TUNBCD  ;��TUNBCD�д���A������

//			MOV A,41H     ;����IN1�����ȵ�ż�¶�
//			MOV R1,#56H   ;�ȵ�ż�¶�С��������ʮ������54H,55H,56H
//			ACALL TUNBCD  ;��TUNBCD�д���A������

			
							
			ACALL DISPLAY					 ;ˢ�������
			SJMP LOOP						 ;��ѭ�����ȴ��ж�

			ORG 0200H
PINT0:		
            PUSH PSW
            PUSH ACC
			;PUSH R3                          ;��֪����û�б�Ҫ						 ;�����ط�û�õ�R3	�ҹ����Ĵ������ܽ�ջ ������ERROR
			MOV DPTR, #0DFF8H				 ;ָ��IN0ͨ��		 					 ;Ӧ����0DFF8H?(ͨ��0��
			MOVX A,@DPTR					 ;ת������������ת�����
			MOV @R0,A						 ;�����ڲ�RAM�洢��
			INC R0																	   ;û����ΪʲôҪ��һR0
			INC DPTR
			DJNZ R2,NEXT
			MOV R0,#40H					                                                                                                  ;���������׵�ַ
			MOV R2,#01H	                                                                                                                  ;�ٴζ�R2��ͨ������ת�����������ͨ����
			;CLR EX0																	 ;ΪʲôҪ�ر��ж�ʹ�ܣ�	��R2û�����¸�ֵ
			SJMP DONE
NEXT:       MOVX @DPTR,A					 ;�ٴ�����������ת����R2��ͨ��
            ;POP R3
            POP ACC
			POP PSW
DONE:       MOV DPTR, #0DFF8H				 ;ָ��IN0ͨ��
            MOVX @DPTR,A					 ;�ٴ���������һ���¶�ˢ��
            RETI


;*************************************
;* ��ʾ����תΪ��λBCD����� *
;*************************************
;��ʾ����תΪ��λBCD�����32H��31H��30H(���ֵ5.00v)
;
TUNBCD:  ;255/51=5.00V����
		 MOV B,#51 ;
		 DIV AB ;
		 MOV @R1,A ;����Ϊʮλ���ŵ������������
		 DEC R1	   ;R4�����λ�ĵ�ַ
		
;**********���´�������**************;
		 MOV A,B ;��������19H,F0Ϊ1,�˷����,�����5
		 CLR F0
		 SUBB A,#1AH
		 MOV F0,C
		 MOV A,#10 ;
		 MUL AB ;
		 MOV B,#51 ;
		 DIV AB
		 JB F0,LOOP2 ;
		 ADD A,#5
		LOOP2: MOV @R1,A ;��λ���ڶ��������
		 DEC R1	   ;R4����С��λ�ĵ�ַ
		 MOV A,B
		 CLR F0
		 SUBB A,#1AH
		 MOV F0,C
		 MOV A,#10 ;
		 MUL AB ;
		 MOV B,#51 ;
		 DIV AB
		 JB F0,LOOP3 ;
		 ADD A,#5
		LOOP3: MOV @R1,A ;С��λ����һ�������
;**********�����������**************;
	
         RET
;

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