  ORG 0000H
  LJMP BEGIN
  ORG 0013H	     ;�ⲿ�ж�1�����
  LJMP INTT1	 ;�����ⲿ�ж�
  ORG 0060H	
  PROTECTION EQU 3AH
  
BEGIN:
  SETB EA	    ;���жϿ��ش�
  SETB EX1	    ;�ⲿ�ж�1��������
  SETB IT1	    ;�������ж�1,���˿��Ƿ����ж��ź�
  MOV SP,#70H	;��ջָ������
  MOV DPTR,#0DFFAH ;����ADת����֮��ȴ�ADģ��ת�������������ж�����
  MOVX @DPTR,A	   ;����ADת����֮��ȴ�ADģ��ת�������������ж�����
  CLR P1.6
MAIN: 
  LCALL BCD         ;��ʾ�趨ֵ��ͬʱ���趨ֵתΪʮ�����ƴ���R2��
  LCALL TEMTRANS    ;�ɼ����ݵ�ʮ������ת��
  LCALL DISPLAY     ;��ʾ����
  MOV A,R7          ;R7Ϊ�ⶨֵ
  MOV 50H,R2        ;R2Ϊ�趨ֵ
  CJNE A,50H,X1     ;���߱Ƚϣ���ҪΪ���жϴ�С��ʵ���¶ȴ���CYΪ0
  CPL P1.6
X1: JNB CY,STOP	    ;CYΪ0����ʵ���¶ȴ�����STOPֹͣ����
H1:		    ;CYΪ1��δ��Ԥ��ֵ���ж��²Χ
  MOV A,R2          
  CLR C
  SUBB A,#0AH         ;��Ԥ��ֵ��С10��
  MOV 55H,A  
  MOV A,R7
  CJNE A,55H,X2     ;�ٴαȽ�
X2: JNB CY,H2       ;ʵ���¶ȴ�����X3�ٴαȽ�
   LJMP HEAT        ;ʵ���¶�С������HEAT�������ȳ���
X3:		    
  MOV A,R2          
  CLR C
  SUBB A,#05H         ;��Ԥ��ֵ��С5��
  MOV 56H,A  
  MOV A,R7
  CJNE A,56H,X4     ;�ٴαȽ�
X4: JNB CY,H3       ;ʵ���¶ȴ�����H3����˸���ȳ���
   LJMP HEAT        ;ʵ���¶�С������H2����˸���ȳ���
										
H2:
  MOV R4,#0FH
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	     ;����ָ������̵�����ַ
  LCALL DELAY1S
  LCALL DELAY1S       ;����2s
  MOV R4,#0F0H
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	      ;ָֹͣ������̵�����ַ
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S        ;ֹͣ4s
  LJMP MAIN           

H3:
  MOV R4,#0FH
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	     ;����ָ������̵�����ַ
  LCALL DELAY1S       ;����1s
  MOV R4,#0F0H
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	      ;ָֹͣ������̵�����ַ
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S        ;ֹͣ5s
  LJMP MAIN           

HEAT:			    ;�²�10�����ϣ���������
  MOV R4,#0FH		;��������
  AJMP KAIGUAN		;�����̵�������
STOP:
  MOV R4,#0F0H		;ֹͣ����
KAIGUAN:
  MOV A,R4
  MOV DPTR,#7FFCH	 ;��������̵���
  MOVX @DPTR,A		 ;��������̵���
  LCALL DELAY1S		 ;������ʱ�ӳ���
  LJMP MAIN

DELAY1_10S:
	MOV TMOD,#10H   ;�趨��ʱ��1λ��ʽһ
	MOV TH1,#3CH
	MOV TL1,#0B0H;
	SETB TR1
L2:	JBC TF1,L1
	SJMP L2			;�ٶ�ʱ��Ƶ��Ϊ6Mhz
L1:	
	CLR TR1
	RET

DELAY1S:
	MOV R0,#10;
	MOV TMOD,#10H   ;�趨��ʱ��1λ��ʽһ
	MOV TH1,#3CH
	MOV TL1,#0B0H;
	SETB TR1
L4:	JBC TF1,L3
	SJMP L4
L3:	
	MOV TH1,#3CH
	MOV TL1,#0B0H
	DJNZ	R0,L4
	CLR TR1
	RET

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
  RET			 ;�ӳ��򷵻�



INTT1:
  CLR EX1
  MOV PROTECTION,A  ;����ԭ�����ۼ���
  MOV DPTR,#0DFFAH	;��ת��ֵ
  MOVX A,@DPTR		;��ת��ֵ
  MOV R3,A			; �Ĵ�ת��ֵ
  MOVX @DPTR,A		;����ADת��
  MOV A,PROTECTION	;�ָ�
  SETB EX1
  RETI				;���ضϵ�

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