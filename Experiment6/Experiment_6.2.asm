  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			;ORG 0023H
			;AJMP UARTINT
			ORG 0060H

START:	 	MOV SP,#5FH
			MOV TMOD,#21H	;定时器1模式2工作，用于控制波特率; 定时器0用于3s定时
			MOV PCON,#00H 	;不分频
			MOV TH1,#0FDH	;波特率9600
			MOV TL1,#0FDH	;波特率9600
			MOV SCON, #50H ;串口工作方式1
			MOV TH0,#4CH   ;定时50ms
   			MOV TL0,#00H   ;定时50ms
			
			SETB REN	 	;允许接受
			SETB TR1		;T1开始工作
			SETB PS 		;设置串口优先级为高
			SETB ES			;使能串口中断
			SETB ET0		;使能定时器0中断
			SETB EA			;使能所有中断

			MOV WORD_CNT,#0H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		MOV A,TIME_FLAG
			CJNE A,#1H,SKIP			   ;检查是否达到3s定时

SEND:		MOV	DPTR,#DSEG1			   ;DSEG1中存放发送内容的ASCII码
			MOV A, WORD_CNT
			MOVC A,@A+DPTR		   ;第WOED_CNT个字节对应的ASCII码放入ACC
			MOV SBUF,A				   ;发送ACC中内容
;WAIT:		JNB TI,WAIT
			JNB TI,$				   ;等待发送完毕（TI=1)
			CLR TI					   ;TI清零
			INC WORD_CNT			   ;指向字节加一
			MOV A,WORD_CNT
			CJNE A,#5H,SEND			   ;判断是否全部发送完毕，待修改
			MOV WORD_CNT ,#0H		   ;发送完毕则重置WORD_CNT
			 
SKIP:		SJMP LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;定时器中断
TIMINT:		MOV TH0,#4CH	 	;重置初值
			MOV TL0,#0H

			INC TCOUNT
			MOV A,TCOUNT
			CJNE A,#60,NEXT_TINT	;50ms计数为达60次，即3s，跳出
			MOV TCOUNT,#0H		 	;重置50ms计数器TCOUNT
			MOV TIME_FLAG,#1H	 	;置3s定时flag为1

NEXT_TINT:
			RETI

DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,59H,6EH,61H	 ; hina
		  DB 21H				 ; !

			END