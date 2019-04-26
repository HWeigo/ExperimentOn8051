			ORG 0000H
			AJMP MAIN		
			ORG 0003H
			AJMP PINT0
					
			ORG  0100H
MAIN:		
            ;初始化
			MOV	30H,#0H
			MOV 31H,#0H
			MOV	32H,#0H
			MOV 33H,#0H
	

			MOV R0,#40H						 ;置数据区首地址
			MOV R2,#01H						 ;总查询通道数在这里改通道数
			SETB IT1						 ;开中断                                 ;应使用中断源INT0?（8090EOC接INT1)
			SETB EA
			SETB EX0
			;第一次开启AD转换
			MOV DPTR, #0DFF8H				 ;A13=0,并指向IN0通道		 			 ;应该是0DFF8H?(通道0）
			MOVX @DPTR,A					 ;启动AD转换
LOOP:
			MOV A,40H     ;处理IN0，得空气温度
			MOV R1,#32H   ;空气温度小数、个、十放置于30H,31H,32H，R1存放ADC数字量置数区
			ACALL TUNBCD  ;在TUNBCD中处理A的数据

//			MOV A,41H     ;处理IN1，得热电偶温度
//			MOV R1,#56H   ;热电偶温度小数、个、十放置于54H,55H,56H
//			ACALL TUNBCD  ;在TUNBCD中处理A的数据

			
							
			ACALL DISPLAY					 ;刷新数码管
			SJMP LOOP						 ;死循环，等待中断

			ORG 0200H
PINT0:		
            PUSH PSW
            PUSH ACC
			;PUSH R3                          ;不知道有没有必要						 ;其他地方没用到R3	且工作寄存器不能进栈 编译有ERROR
			MOV DPTR, #0DFF8H				 ;指向IN0通道		 					 ;应该是0DFF8H?(通道0）
			MOVX A,@DPTR					 ;转换结束，读入转换结果
			MOV @R0,A						 ;存入内部RAM存储区
			INC R0																	   ;没明白为什么要加一R0
			INC DPTR
			DJNZ R2,NEXT
			MOV R0,#40H					                                                                                                  ;置数据区首地址
			MOV R2,#01H	                                                                                                                  ;再次对R2个通道进行转换，在这里改通道数
			;CLR EX0																	 ;为什么要关闭中断使能？	且R2没有重新赋值
			SJMP DONE
NEXT:       MOVX @DPTR,A					 ;再次启动，依次转换完R2个通道
            ;POP R3
            POP ACC
			POP PSW
DONE:       MOV DPTR, #0DFF8H				 ;指向IN0通道
            MOVX @DPTR,A					 ;再次启动，新一轮温度刷新
            RETI


;*************************************
;* 显示数据转为三位BCD码程序 *
;*************************************
;显示数据转为三位BCD码存入32H、31H、30H(最大值5.00v)
;
TUNBCD:  ;255/51=5.00V运算
		 MOV B,#51 ;
		 DIV AB ;
		 MOV @R1,A ;整数为十位，放到第三个数码管
		 DEC R1	   ;R4放入个位的地址
		
;**********以下处理余数**************;
		 MOV A,B ;余数大于19H,F0为1,乘法溢出,结果加5
		 CLR F0
		 SUBB A,#1AH
		 MOV F0,C
		 MOV A,#10 ;
		 MUL AB ;
		 MOV B,#51 ;
		 DIV AB
		 JB F0,LOOP2 ;
		 ADD A,#5
		LOOP2: MOV @R1,A ;个位，第二个数码管
		 DEC R1	   ;R4放入小数位的地址
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
		LOOP3: MOV @R1,A ;小数位，第一个数码管
;**********余数处理完毕**************;
	
         RET
;

;***********数码管刷新*************;
DISPLAY:	
            ;第一位
			MOV	DPTR,#DSEG1
			MOV  A,30H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H		     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;第二位
			MOV	DPTR,#DSEG1
			MOV A,31H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第三位
			MOV	DPTR,#DSEG1
			MOV A,32H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第四位
			MOV	DPTR,#DSEG1
			MOV A,33H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF3H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			RET

DELAY_SHORT:                      ;延迟
           MOV R7,#10
DEL_SHORT: MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_SHORT
           RET

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H  ;段码
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH


          END                  