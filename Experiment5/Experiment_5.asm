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

				CPL P1.6		;���Ź�����

				CLR C
				MOV A,R7		  ;R7ʵ��ˮ��
				MOV 50H,R2  	  ;R2�趨ˮ��
				CJNE A,50H,COMPARE1       ;ʵ��ˮ��>�趨ˮ��,CY=0,ʵ��ˮ��<�趨ˮ��,CY=1

COMPARE1:		JNB CY,STOP

				MOV A,R2
				SUBB A,#5H		  ;�����¶ȼ�5
				CLR C			  ;��ձ�־λ
				MOV A,R7		  ;ʵ���¶�
				MOV 51H,A		  ;�趨�¶�-5
				CJNE A,51H,COMPARE2		  ;ʵ���¶�>�趨�¶ȣ��������ڣ�,CY=0

COMPARE2:		JNB CY,FLASH
				
				LCALL TURNON
				LJMP LOOP


FLASH:			LCALL TURNON
				ACALL DELAY_LONG
				ACALL DELAY_LONG
				ACALL DELAY_LONG
				LCALL TURNOFF
				ACALL DELAY_LONG
				LJMP LOOP
				

STOP:			LCALL TURNOFF	 ;�رռ̵���
				LJMP LOOP		 ;����LOOP

				SJMP LOOP
				RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;���̵�����ʹ�� LCALL TURNON��
TURNON:			MOV R4,#0FH
				MOV A,R4
				MOV DPTR,#7FFCH
				MOVX @DPTR,A
				LCALL DELAY_LONG
				RET

;�ؼ̵�����ʹ�� LCALL TURNOFF��
TURNOFF:		MOV R4,#0H
				MOV A,R4
				MOV DPTR,#7FFCH
				MOVX @DPTR,A
				LCALL DELAY_LONG
				RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INTT1:
			  CLR EX1
			  MOV PROTECTION,A  ;����ԭ�����ۼ���
			  MOV DPTR,#0DFFAH	;��ת��ֵ
			  MOVX A,@DPTR		;��ת��ֵ		  6
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
			  MOV B,#100     
			  MUL AB	 
			  MOV R7,B	     ;B�������¶�ֵ
			  MOV A,R7	     ;����ˮ�µ�ǰ����λ
			  MOV B,#0AH  
			  DIV AB	   
			  MOV 31H,A		 ;ʮλ�ŵ������2
			  MOV 30H,B		 ;��λ�ŵ������1
			  RET			 ;�ӳ��򷵻�
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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