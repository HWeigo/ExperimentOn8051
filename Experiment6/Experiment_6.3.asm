			MINUTE_HIGH EQU 30H
			MINUTE_LOW EQU 31H
			SECOND_HIGH EQU 32H
			SECOND_LOW EQU 33H 
			LETTER1 EQU 34H
			LETTER2 EQU 35H
			LETTER3 EQU 36H
			LETTER4 EQU 37H
			LETTERCNT EQU 38H
			ORG 0000H
			LJMP BEGIN
			ORG 0060H

BEGIN:
			MOV TMOD,#20H			;定时器1模式2工作
			MOV TH1,#0FDH			;波特率9600
			MOV TL1,#0FDH			;波特率9600
			SETB TR1				;T1开始工作
			MOV SCON,#50H

MAIN:
			MOV MINUTE_HIGH,#00H
			MOV MINUTE_LOW,#00H
			MOV SECOND_HIGH,#00H
			MOV SECOND_LOW,#00H
			MOV LETTER1,#0H
			MOV LETTER2,#0H
			MOV LETTER3,#0H
			MOV LETTER4,#0H
			MOV LETTERCNT,#34H
NOTRECEIVE:
			JBC RI,L1				;判断是否有串口数据输入
			LJMP NOTRECEIVE

RX:
			MOV A,SBUF				 ;接受串口数据
			MOV @LETTERCNT,A		 ;储存字节
			ANL A,#0FH				 ;隔离高位
			MOV MINUTE_HIGH,A		 ;将低位放至寄存器
			MOV A,R1
			ANL A,#0F0H				 ;隔离低位
			SWAP A					 ;交换高低位
			MOV MINUTE_LOW,A		 ;将低位放至寄存器
			ADD LETTERCNT			 ;字节计数加一
			MOV A,LETTERCNT
			CJNE A,#39H,RX			 ;若未到4位字节则继续读取
			MOV LETTERCNT,#34H
			LCALL DISPLAY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADD1:
			MOV A,LETTER1
			MOV B,LETTER2
			CLR CY
			ADD A,B
			DA A				   ;字节十进制相加
			MOV R5,A			   ;存储累加数
			MOV R6,#00H
			JNC ADD2			   ;若无进位则跳转

			INC R6				   ;若有进位则百位加一

ADD2:
			MOV A,R5
			MOV B,R3
			CLR CY
			ADD A,B
			DA A				   ;字节十进制相加
			MOV R5,A
			JNC ADD3

			INC R6

ADD3:
			MOV A,R5
			MOV B,R4
			CLR CY
			ADD A,B
			DA A				   ;字节十进制相加
			MOV R5,A
			JNC TOTAL

			INC R6
			MOV A,R6
			MOV SECOND_HIGH,A

TOTAL:
			MOV A,R5
			ANL A,#0FH
			MOV MINUTE_HIGH,A
			MOV A,R5
			ANL A,#0F0H
			SWAP A
			MOV MINUTE_LOW,A
			LCALL DISPLAY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;串口发送
SEND:

			MOV LETTERCNT,#39H
			MOV A,LETTERCNT
			MOV SBUF,A				   ;发送ACC中内容
WAIT:		JNB TI,WAIT
			CLR TI					   ;TI清零
			INC LETTERCNT			   ;指向字节加一
			MOV A,LETTERCNT
			CJNE A,#H,SEND			   ;判断是否全部发送完毕，待修改
			MOV LETTERCNT ,#34H		   ;发送完毕则重置WORD_CNT
						
			LJMP MAIN

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
