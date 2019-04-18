  		    SECOND_LOW EQU 30H
			SECOND_HIGH EQU 31H
			MINUTE_LOW EQU 32H
			MINUTE_HIGH EQU 33H
			TCOUNT EQU 34H
						
  		    ORG 0H
			AJMP MAIN		
			ORG 000BH
			AJMP TINT0

			ORG  60H
MAIN:		
			;初始化
			MOV	30H,#0H
			MOV 31H,#0H
			MOV	32H,#0H
			MOV 33H,#0H
			MOV 34H,#0H
			MOV FLAG,#0H

			;定时器中断使能
			MOV TMOD,#01H 		;t0使用模式1定时器
			MOV TH0,#04CH	 		;设置定时50ms
			MOV TL0,#0H
			SETB ET0		 	;t1允许中断
			SETB TR0 			;启动定时
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main函数			
LOOP:	  	;按键检测
			JNB P1.0,CLEAR
			JNB P1.1,STOP
			JNB P1.2,START
			ACALL DISPLAY

			SJMP LOOP			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;清零
CLEAR:			 		
			MOV	SECOND_LOW,#0H
			MOV SECOND_HIGH,#0H
			MOV	MINUTE_LOW,#0H
			MOV MINUTE_HIGH,#0H
			MOV TCOUNT,#0H
			LJMP LOOP
			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;暂停与继续
STOP:		CLR ET0
			LJMP LOOP
			;RET

START:		SETB ET0
			LJMP LOOP
			;RET

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;定时INC寄存器
			
TINT0:		MOV TH0,#04CH	 	;重置初值
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
DISPLAY:	;第一个数码管
			MOV	DPTR,#DSEG1
			MOV  A,30H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF0H		     
			MOVX	@DPTR,A
			ACALL DELAY_SHORT

			;第二个数码管
			MOV	DPTR,#DSEG1
			MOV A,31H
			MOVC	A,@A+DPTR
			MOV	DPTR,#7FF1H			     
			MOVX	@DPTR,A
			ACALL DELAY_SHORT

			;第三个数码管
			MOV	DPTR,#DSEG1
			MOV A,32H
			MOVC	A,@A+DPTR
			CLR ACC.7				 	;点亮小数点位
			MOV	DPTR,#7FF2H			     
			MOVX	@DPTR,A
			ACALL DELAY_SHORT

			;第四个数码管
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

DELAY_LONG:                   
           MOV R7,#250
DEL_LONG:  MOV R6,#250
           DJNZ R6,$
           DJNZ R7,DEL_LONG
           RET

DSEG1:    DB 0C0H,0F9H,0A4H,0B0H                        
          DB 99H,92H,82H,0F8H
          DB 80H,90H,88H,83H
          DB 0C6H,0A1H,86H,8EH

          END                  