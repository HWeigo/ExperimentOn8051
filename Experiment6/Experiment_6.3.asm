  		    TIME_FLAG EQU 30H
			TCOUNT EQU 31H
			WORD_CNT EQU 32H
			NUM1 EQU 33H
			NUM2 EQU 34H
			NUM3 EQU 35H
			NUM4 EQU 36H
			NUM_FLAG EQU 37H
			NUM_TOTAL EQU 38H

			ORG 0000H
			AJMP START
			ORG 000BH
			AJMP TIMINT
			ORG 0023H
			AJMP UARTINT
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
			MOV NUM_FLAG,#0H
			MOV R7,#04H
			MOV R0,#33H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOOP:		
			MOV A,NUM_FLAG
			CJNE A,#1H,SKIP			  ;若数字不足4个则循环

			MOV A,#0H
			ADD A,NUM1
			ADD A,NUM2
			ADD A,NUM3
			ADD A,NUM4				  ;累加
			MOV NUM_TOTAL,A 

SEND:		
			MOV SBUF,A				   ;发送ACC中内容
			JNB TI,$				   ;等待发送完毕（TI=1)
			CLR TI					   ;TI清零
			 
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;串口中断
UARTINT:	
			PUSH PSW
			PUSH ACC			   ;现场保护
			CLR ES				   ;关闭串口中断
							  

			MOV A,SBUF			   ;将串口读取存至寄存器A
			MOV @R0,A			   ;将A存至R0指向地址（R0->33H,34H,35H,36H)
			INC R0				   ;R0加一
			DJNZ R7,EXIT		   ;判断是否有4个数输入，没有则退出
			MOV R0,#33H			   ;重置R0初值
			MOV R7,#04H			   ;重置R7计数
			MOV NUM_FLAG,#1H	   ;将标志位置1

EXIT:
			CLR RI
			SETB ES
			POP ACC
			POP PSW
			RETI	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DSEG1:    DB 49H,20H,4CH,6FH	 ; I Lo
		  DB 76H,65H,20H,43H     ; ve C
		  DB 68H,59H,6EH,61H	 ; hina
		  DB 21H				 ; !

DSEG2:    DB 30H,31H,32H,33H
		  DB 34H,35H,36H,37H     ; 0-9
		  DB 38H,39H

			END