  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H
			SECOND_LOW EQU 40H
			SECOND_HIGH EQU 41H
			MINUTE_LOW EQU 42H
			MINUTE_HIGH EQU 43H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			;ORG 0023H
			;AJMP UARTINT
			ORG 0060H

START:	 	MOV SP,#0060H
			MOV SCON,#40H	;设置串口为模式1工作
			MOV PCON,#00H 	;不分频
			MOV TMOD,#21H	;定时器1模式2工作，用于控制波特率; 定时器0用于3s定时
			MOV TH1,#0FDH	;波特率9600
			MOV TL1,#0FDH	;波特率9600
			MOV TH0,#4CH    ;定时50ms
   			MOV TL0,#00H    ;定时50ms

			SETB REN	 	;允许接受
			SETB TR1		;T1开始工作
			SETB TR0
			SETB ET0		;使能定时器0中断
			SETB EA			;使能所有中断

			MOV TIME_FLAG,#0H
			MOV WORD_CNT,#1H
			MOV SECOND_LOW,#1H
			MOV SECOND_HIGH,#0H
			MOV MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		
			MOV A,30H
			CJNE A,#1H,SKIP			   ;检查是否达到3s定时

SEND:		
			MOV 30H,#0H
            MOV	DPTR,#DSEG1			   ;DSEG1中存放发送内容的ASCII码
			MOV A, WORD_CNT
			MOVC A,@A+DPTR		   ;第WOED_CNT个字节对应的ASCII码放入ACC
			MOV SBUF,A				   ;发送ACC中内容
WAIT:		JNB TI,WAIT
			CLR TI					   ;TI清零
			INC WORD_CNT			   ;指向字节加一
			MOV A,WORD_CNT
			CJNE A,#10H,SEND			   ;判断是否全部发送完毕，待修改
			MOV WORD_CNT ,#0H		   ;发送完毕则重置WORD_CNT
			 
SKIP:		SJMP LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;定时器中断
TIMINT:		
			PUSH ACC
			MOV TH0,#4CH	 	;重置初值
			MOV TL0,#0H

			INC 31H
			MOV A,31H
			CJNE A,#20,NEXT_TINT	;50ms计数为达60次，即3s，跳出
			MOV 31H,#0H		 	    ;重置50ms计数器TCOUNT
			MOV 30H,#1H	        	;置3s定时flag为1
			INC MINUTE_LOW

NEXT_TINT:
			POP ACC
			RETI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;数码管显示
DISPLAY:	;第一个数码管
			MOV	DPTR,#DSEG3
			MOV  A,MINUTE_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H			     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;第二个数码管
			MOV	DPTR,#DSEG3
			MOV A,MINUTE_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第三个数码管
			MOV	DPTR,#DSEG3
			MOV A,SECOND_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第四个数码管
			MOV	DPTR,#DSEG3
			MOV A,SECOND_LOW
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
           MOV R7,#100
DEL_LONG:  MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_LONG
           RET

DSEG3:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,105,6EH,61H	 ; hina
		  DB 21H				 ; !

			END