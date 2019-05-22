			  PROTECTION EQU 3AH

			  ORG 0000H
			  LJMP BEGIN
			  ORG 0013H	     ;外部中断1的入口
			  LJMP INTT1	 ;调到外部中断
			  ORG 0060H	


BEGIN:
			  	SETB EA	    ;总中断开关打开
			 	SETB EX1	    ;外部中断1允许启用
			 	SETB IT1	    ;开启外中断1,检查端口是否有中断信号
			 	MOV SP,#70H	;堆栈指针设置
			 	MOV DPTR,#0DFFAH ;启动AD转换，之后等待AD模块转换结束，发出中断请求
			 	MOVX @DPTR,A	   ;启动AD转换，之后等待AD模块转换结束，发出中断请求
			 	CLR P1.6
MAIN: 

LOOP: 			LCALL BCD         ;显示设定值，同时将设定值转为十六进制存在R2中
			 	LCALL TEMTRANS    ;采集数据的十六进制转换
			  	LCALL DISPLAY     ;显示程序

				CPL P1.6		;看门狗脉冲

				CLR C
				MOV A,R7		  ;R7实际水温
				MOV 50H,R2  	  ;R2设定水温
				CJNE A,50H,COMPARE1       ;实际水温>设定水温,CY=0,实际水温<设定水温,CY=1

COMPARE1:		JNB CY,STOP

				MOV A,R2
				SUBB A,#5H		  ;设置温度减5
				CLR C			  ;清空标志位
				MOV A,R7		  ;实际温度
				MOV 51H,A		  ;设定温度-5
				CJNE A,51H,COMPARE2		  ;实际温度>设定温度（缓冲区内）,CY=0

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
				

STOP:			LCALL TURNOFF	 ;关闭继电器
				LJMP LOOP		 ;跳回LOOP

				SJMP LOOP
				RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;开继电器（使用 LCALL TURNON）
TURNON:			MOV R4,#0FH
				MOV A,R4
				MOV DPTR,#7FFCH
				MOVX @DPTR,A
				LCALL DELAY_LONG
				RET

;关继电器（使用 LCALL TURNOFF）
TURNOFF:		MOV R4,#0H
				MOV A,R4
				MOV DPTR,#7FFCH
				MOVX @DPTR,A
				LCALL DELAY_LONG
				RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INTT1:
			  CLR EX1
			  MOV PROTECTION,A  ;保存原来的累加器
			  MOV DPTR,#0DFFAH	;读转换值
			  MOVX A,@DPTR		;读转换值		  6
			  MOV R3,A			;读数储存至R3
			  MOVX @DPTR,A		;启动AD转换
			  MOV A,PROTECTION	;恢复
			  SETB EX1
			  RETI				;返回断点
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BCD:
			  CLR P1.7		   ;选择拨码盘前两位
			  MOV DPTR,#0BFFFH
			  MOVX A,@DPTR	   ;读出拨码盘8位二进制数
			  CPL A			   ;取反
			  MOV B,#10H	   ;分离前四位和后四位
			  DIV AB		   ;分离前四位和后四位
			  MOV 32H,B		   ;设定温度值得个位存入数码管3
			  MOV 33H,A		   ;设定温度值得十位存入数码管4
			  MOV B,#0AH	   ;赋予B为10
			  MUL AB		   ;十位数乘10得到其十六进制表达
			  ADD A,32H		   ;加上个位数
			  MOV R2,A		   ;设定值成即转换为十六进制
			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TEMTRANS:		 ;采集到温度值的十进制转换
			  MOV A,R3	  
			  MOV B,#100     
			  MUL AB	 
			  MOV R7,B	     ;B：测量温度值
			  MOV A,R7	     ;分离水温的前后四位
			  MOV B,#0AH  
			  DIV AB	   
			  MOV 31H,A		 ;十位放到数码管2
			  MOV 30H,B		 ;个位放到数码管1
			  RET			 ;子程序返回
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
DISPLAY:	   ;显示函数
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
DSEG1:				  ;段码表
				DB 0C0H,0F9H,0A4H,0B0H
				DB 99H,92H,82H,0F8H
				DB 80H,90H,88H,83H
				DB 0C6H,0A1H,86H,8EH
				  
				  END