			  PROTECTION EQU 3AH

			  ORG 0000H
			  LJMP BEGIN
			  ORG 0013H	     ;�ⲿ�ж�1�����
			  LJMP INTT1	 ;�����ⲿ�ж�
			  ORG 0060H	


BEGIN:
			  	SETB EA	    ;���жϿ��ش�
			 	SETB EX1	    ;�ⲿ�ж�1��������
			 	SETB IT1	    ;�������ж�1,���˿��Ƿ����ж��ź�
			 	MOV SP,#70H	;��ջָ������
			 	MOV DPTR,#0DFFAH ;����ADת����֮��ȴ�ADģ��ת�������������ж�����
			 	MOVX @DPTR,A	   ;����ADת����֮��ȴ�ADģ��ת�������������ж�����
			 	CLR P1.6
MAIN: 

LOOP: 			LCALL BCD         ;��ʾ�趨ֵ��ͬʱ���趨ֵתΪʮ�����ƴ���R2��
			 	LCALL TEMTRANS    ;�ɼ����ݵ�ʮ������ת��
			  	LCALL DISPLAY     ;��ʾ����

				SJMP LOOP
				

				RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INTT1:
			  CLR EX1
			  MOV PROTECTION,A  ;����ԭ�����ۼ���
			  MOV DPTR,#0DFFAH	;��ת��ֵ
			  MOVX A,@DPTR		;��ת��ֵ
			  MOV R3,A			;����������R3
			  MOVX @DPTR,A		;����ADת��
			  MOV A,PROTECTION	;�ָ�
			  SETB EX1
			  RETI				;���ضϵ�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BCD:
			  CLR P1.7		   ;ѡ������ǰ��λ
			  MOV DPTR,#0BFFFH
			  MOVX A,@DPTR	   ;����������8λ��������
			  CPL A			   ;ȡ��

			  ; MOV R2,A

			  MOV B,#10H	   ;����ǰ��λ�ͺ���λ
			  DIV AB		   ;����ǰ��λ�ͺ���λ
			  MOV 32H,B		   ;�趨�¶�ֵ�ø�λ���������3
			  MOV 33H,A		   ;�趨�¶�ֵ��ʮλ���������4


			  MOV B,#0AH	   ;����BΪ10
			  MUL AB		   ;ʮλ����10�õ���ʮ�����Ʊ��
			  ADD A,32H		   ;���ϸ�λ��
			  MOV R2,A		   ;�趨ֵ�ɼ�ת��Ϊʮ������


			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TEMTRANS:		 ;�ɼ����¶�ֵ��ʮ����ת��
			  MOV A,R3	  
			  MOV B,#100     ;�ɼ�����8λ���������ȳ���100���ٳ���256���ǲɼ�����ˮ��
			  MUL AB	 
			  MOV R7,B	     ;�˻��ĸ߰�λ�����B���Ͱ�λ����A�����������256���൱����������ұ��ƶ���λ������B����ˮ���¶�ֵ
			  MOV A,R7	     ;����ˮ�µ�ǰ����λ�����ڵ�ˮ����ʮ�����Ƶģ�����λ��ֵ���ᳬ��15��
			  MOV B,#0AH  
			  DIV AB	   
			  MOV 31H,A		 ;ʮλ�ŵ������2
			  MOV 30H,B		 ;��λ�ŵ������1
			  RET			 ;�ӳ����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY:	   ;��ʾ����
			  MOV A,30H
			  ANL A,#0FH
			  MOV DPTR,#DSEG1
			  MOVC A,@A+DPTR
			  MOV DPTR,#7FF8H
			  MOVX @DPTR,A
			
			  MOV A,31H
			  ANL A,#0FH
			  MOV DPTR,#DSEG1
			  MOVC A,@A+DPTR
			  MOV DPTR,#7FF9H
			  MOVX @DPTR,A
			
			  MOV A,32H
			  ANL A,#0FH
			  MOV DPTR,#DSEG1
			  MOVC A,@A+DPTR
			  MOV DPTR,#7FFAH
			  MOVX @DPTR,A
			
			  MOV A,33H
			  ANL A,#0FH
			  MOV DPTR,#DSEG1
			  MOVC A,@A+DPTR
			  MOV DPTR,#7FFBH
			  MOVX @DPTR,A
			  RET
DSEG1:				  ;�����
				DB 0C0H,0F9H,0A4H,0B0H
				DB 99H,92H,82H,0F8H
				DB 80H,90H,88H,83H
				DB 0C6H,0A1H,86H,8EH
				  
				  END