  		    SECOND_LOW EQU 30H
			SECOND_HIGH EQU 31H
			MINUTE_LOW EQU 32H
			MINUTE_HIGH EQU 33H
			TCOUNT EQU 34H
			
			ORG 0H
			AJMP MAIN
			ORG 0003H
			AJMP INTF
			ORG 000BH
			AJMP TINT0
			ORG 0013H
			AJMP INTS

			ORG 60H

MAIN:		;初始化
			MOV SECOND_LOW,#0H
			MOV SECOND_HIGH,#0H
			MOV MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			MOV TCOUNT,#0H
			MOV R1,#0H 		;R1作为暂停用flag
			
			SETB EA			;CPU允许中断
			
			;外部中断初始化
			CLR IT0			;设置外部中断触发方式
			CLR IT1
			SETB PX0		;设置INT0高优先级
			CLR PX1			;设置INT1高优先级
			SETB EX0		;开放中断
			SETB EX1
		

			;定时器中断初始化
			MOV TMOD,#01H 	;t0使用模式1定时器
			MOV TH0,#4CH	;设置定时50ms
			MOV TL0,#0H
			SETB ET0		;t1允许中断						 
			SETB TR0 		;启动定时						 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			

LOOP:	   	AJMP DISPLAY
			SJMP LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;外部中断INT0用于切换R1（状态机，用作暂停flag）
;R1-0运行，R1-1暂停
			ORG 0110H
INTF:		INC R1
			SETB ET0		
			CJNE R1,#2H,NEXT_INT
			MOV R1,#0H
NEXT_INT:
			CLR ET0
			RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;外部中断INT1用于清零
INTS:		MOV SECOND_LOW,#0H	  ;重置所有寄存器
			MOV SECOND_HIGH,#0H
			MOV MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			MOV TCOUNT,#0H
			
			RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;定时器中断
TINT0:		MOV TH0,#4CH	 	;重置初值
			MOV TL0,#0H

			INC TCOUNT
			MOV A,TCOUNT
			CJNE A,#20,NEXT_TINT	;50ms计数为达20次，跳出
			MOV TCOUNT,#0H		 	;重置50ms计数器TCOUNT
			INC SECOND_LOW			;秒个位数加1
			MOV A,SECOND_LOW
			CJNE A,#10,NEXT_TINT	;秒个位未到10，跳出
			MOV SECOND_LOW,#0H		;重置秒个位
			INC SECOND_HIGH			;秒十位加1
			MOV A,SECOND_HIGH
			CJNE A,#6,NEXT_TINT		;秒十位未到6，跳出
			MOV SECOND_HIGH,#0H		;重置秒十位
			INC MINUTE_LOW			;分个位加1
			MOV A,MINUTE_LOW
			CJNE A,#10,NEXT_TINT	;分个位未到10，跳出
			MOV MINUTE_LOW,#0H		;重置分个位
			INC MINUTE_HIGH			;分十位加1
			MOV A,MINUTE_HIGH
			CJNE A,#6,NEXT_TINT	;分十位未到6，跳出
			MOV MINUTE_HIGH,#0H		;重置分个位

NEXT_TINT:
			RETI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;数码管显示
DISPLAY:	;第一个数码管
			MOV	DPTR,#DSEG1
			MOV  A,MINUTE_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H			     
			MOVX	@DPTR,A
			
			ACALL DELAY_SHORT

			;第二个数码管
			MOV	DPTR,#DSEG1
			MOV A,MINUTE_LOW
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第三个数码管
			MOV	DPTR,#DSEG1
			MOV A,SECOND_HIGH
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A

			ACALL DELAY_SHORT

			;第四个数码管
			MOV	DPTR,#DSEG1
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

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  