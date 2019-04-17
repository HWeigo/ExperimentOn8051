			BCD1_LOW	EQU 30H
			BCD1_HIGH EQU 31H
			BCD2_LOW EQU 32H
			BCD2_HIGH EQU 33H
			TMP EQU 34H

  		    ORG 0H
			AJMP MAIN		
						
			ORG  60H
MAIN:		
			;��ʼ��
			MOV	BCD1_LOW,#0H
			MOV BCD1_HIGH,#0H
			MOV	BCD2_LOW,#0H
			MOV BCD2_HIGH,#0H
			MOV R1,#2H
			MOV R4,#0H
			CLR P1.7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
LOOP:		
			;����ɨ��BCD1,BCD2
			;R1��ΪFLAG�л�
			DJNZ R1,SHIFT
			MOV R1,#2H
SHIFT:		CPL P1.7				;�л�P1.7���л�BCDƬ

			MOV DPTR,#0BFFFH		;ѡ����̵ĵ�ַ
			MOVX A,@DPTR			;������
			MOV TMP,A				;�ݴ�������
			LCALL DELAY_10MS		;��ʱ10ms
			MOVX A,@DPTR		 	;������
			CJNE A,TMP,NEXT_DISPLAY			;������Ϊ����

			CJNE R1,#2,NEXT_BCD

			;BCD1����
			CPL A
			SWAP A
			ANL A,#0FH				;ȷ������λΪ��
			MOV BCD1_HIGH,A			;��A�ƶ����Ĵ���,��λ
			MOV A,TMP
			CPL A
			ANL A,#0FH				;���θ���λ
			MOV BCD1_LOW,A			;��A�ƶ����Ĵ���,��λ
			AJMP NEXT_DISPLAY

			;BCD2����
NEXT_BCD:
			CPL A
			SWAP A
			ANL A,#0FH				;ȷ������λΪ��
			MOV BCD2_HIGH,A			;��A�ƶ����Ĵ���,��λ
			MOV A,TMP
			CPL A
			ANL A,#0FH				;���θ���λ
			MOV BCD2_LOW,A			;��A�ƶ����Ĵ���,��λ

NEXT_DISPLAY:
			ACALL DISPLAY			;�������ʾ

			SJMP LOOP
			
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

DELAY_10MS:                   		 ;��׼ȷ10ms��ʱ
           MOV R7,#100
DEL_10MS:  MOV R6,#150
           DJNZ R6,$
           DJNZ R7,DEL_10MS
           RET

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  