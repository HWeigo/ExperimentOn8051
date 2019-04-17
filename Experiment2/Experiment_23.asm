			BCD1_LOW	EQU 30H
			BCD1_HIGH EQU 31H
			BCD2_LOW EQU 32H
			BCD2_HIGH EQU 33H
			TMP EQU 34H

  		    ORG 0H
			AJMP MAIN		
						
			ORG  60H
MAIN:		
			;初始化
			MOV	BCD1_LOW,#0H
			MOV BCD1_HIGH,#0H
			MOV	BCD2_LOW,#0H
			MOV BCD2_HIGH,#0H
			MOV R1,#2H
			MOV R4,#0H
			CLR P1.7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
LOOP:		
			;轮流扫描BCD1,BCD2
			;R1作为FLAG切换
			DJNZ R1,SHIFT
			MOV R1,#2H
SHIFT:		CPL P1.7				;切换P1.7，切换BCD片

			MOV DPTR,#0BFFFH		;选择键盘的地址
			MOVX A,@DPTR			;读键盘
			MOV TMP,A				;暂存键盘输出
			LCALL DELAY_10MS		;延时10ms
			MOVX A,@DPTR		 	;读键盘
			CJNE A,TMP,NEXT_DISPLAY			;不等则为抖动

			CJNE R1,#2,NEXT_BCD

			;BCD1处理
			CPL A
			SWAP A
			ANL A,#0FH				;确保高四位为空
			MOV BCD1_HIGH,A			;将A移动至寄存器,高位
			MOV A,TMP
			CPL A
			ANL A,#0FH				;屏蔽高四位
			MOV BCD1_LOW,A			;将A移动至寄存器,低位
			AJMP NEXT_DISPLAY

			;BCD2处理
NEXT_BCD:
			CPL A
			SWAP A
			ANL A,#0FH				;确保高四位为空
			MOV BCD2_HIGH,A			;将A移动至寄存器,高位
			MOV A,TMP
			CPL A
			ANL A,#0FH				;屏蔽高四位
			MOV BCD2_LOW,A			;将A移动至寄存器,低位

NEXT_DISPLAY:
			ACALL DISPLAY			;数码管显示

			SJMP LOOP
			
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

DELAY_10MS:                   		 ;非准确10ms定时
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