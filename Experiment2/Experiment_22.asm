			
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

			;定时器中断使能
			MOV TMOD,#01H 		;t0使用模式1定时器
			MOV TH0,#0FFH	 		;设置定时50ms
			MOV TL0,#0H
			SETB ET0		 	;t1允许中断
			SETB TR0 			;启动定时
			
			
LOOP:	  	;数码管显示
			ACALL DISPLAY

			SJMP LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;定时INC寄存器
			
TINT0:		INC 30H
			INC 31H
			INC 32H
			INC 33H
			
			;检查是否溢出，若溢出重新赋值，否则跳过
			MOV A,30H
			CJNE A,#10H,NEXT_INC0
			MOV 30H,#0H
NEXT_INC0:	MOV A,31H
			CJNE A,#10H,NEXT_INC1
			MOV 31H,#0H
NEXT_INC1:	MOV A,32H
			CJNE A,#10H,NEXT_INC2
			MOV 32H,#0H
NEXT_INC2:	MOV A,33H
			CJNE A,#10H,NEXT_INC3
			MOV 33H,#0H
NEXT_INC3:			
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