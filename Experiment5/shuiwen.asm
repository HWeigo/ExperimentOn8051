  ORG 0000H
  LJMP BEGIN
  ORG 0013H	     ;外部中断1的入口
  LJMP INTT1	 ;调到外部中断
  ORG 0060H	
  PROTECTION EQU 3AH
  
BEGIN:
  SETB EA	    ;总中断开关打开
  SETB EX1	    ;外部中断1允许启用
  SETB IT1	    ;开启外中断1,检查端口是否有中断信号
  MOV SP,#70H	;堆栈指针设置
  MOV DPTR,#0DFFAH ;启动AD转换，之后等待AD模块转换结束，发出中断请求
  MOVX @DPTR,A	   ;启动AD转换，之后等待AD模块转换结束，发出中断请求
  CLR P1.6
MAIN: 
  LCALL BCD         ;显示设定值，同时将设定值转为十六进制存在R2中
  LCALL TEMTRANS    ;采集数据的十六进制转换
  LCALL DISPLAY     ;显示程序
  MOV A,R7          ;R7为测定值
  MOV 50H,R2        ;R2为设定值
  CJNE A,50H,X1     ;两者比较，主要为了判断大小。实际温度大则CY为0
  CPL P1.6
X1: JNB CY,STOP	    ;CY为0，即实际温度大，跳到STOP停止程序
H1:		    ;CY为1，未到预设值，判断温差范围
  MOV A,R2          
  CLR C
  SUBB A,#0AH         ;将预设值减小10度
  MOV 55H,A  
  MOV A,R7
  CJNE A,55H,X2     ;再次比较
X2: JNB CY,H2       ;实际温度大，跳到X3再次比较
   LJMP HEAT        ;实际温度小，跳到HEAT持续加热程序
X3:		    
  MOV A,R2          
  CLR C
  SUBB A,#05H         ;将预设值减小5度
  MOV 56H,A  
  MOV A,R7
  CJNE A,56H,X4     ;再次比较
X4: JNB CY,H3       ;实际温度大，跳到H3长闪烁加热程序
   LJMP HEAT        ;实际温度小，跳到H2短闪烁加热程序
										
H2:
  MOV R4,#0FH
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	     ;加热指令送入继电器地址
  LCALL DELAY1S
  LCALL DELAY1S       ;加热2s
  MOV R4,#0F0H
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	      ;停止指令送入继电器地址
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S        ;停止4s
  LJMP MAIN           

H3:
  MOV R4,#0FH
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	     ;加热指令送入继电器地址
  LCALL DELAY1S       ;加热1s
  MOV R4,#0F0H
  MOV A,R4
  MOV DPTR,#7FFCH	 
  MOVX @DPTR,A	      ;停止指令送入继电器地址
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S
  LCALL DELAY1S        ;停止5s
  LJMP MAIN           

HEAT:			    ;温差10度以上，持续加热
  MOV R4,#0FH		;加热命令
  AJMP KAIGUAN		;跳到继电器开关
STOP:
  MOV R4,#0F0H		;停止命令
KAIGUAN:
  MOV A,R4
  MOV DPTR,#7FFCH	 ;命令送入继电器
  MOVX @DPTR,A		 ;命令送入继电器
  LCALL DELAY1S		 ;调用延时子程序
  LJMP MAIN

DELAY1_10S:
	MOV TMOD,#10H   ;设定定时器1位方式一
	MOV TH1,#3CH
	MOV TL1,#0B0H;
	SETB TR1
L2:	JBC TF1,L1
	SJMP L2			;假定时钟频率为6Mhz
L1:	
	CLR TR1
	RET

DELAY1S:
	MOV R0,#10;
	MOV TMOD,#10H   ;设定定时器1位方式一
	MOV TH1,#3CH
	MOV TL1,#0B0H;
	SETB TR1
L4:	JBC TF1,L3
	SJMP L4
L3:	
	MOV TH1,#3CH
	MOV TL1,#0B0H
	DJNZ	R0,L4
	CLR TR1
	RET

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

TEMTRANS:		 ;采集到温度值的十进制转换
  MOV A,R3	  
  MOV B,#100     ;采集到的8位二进制数先乘以100，再除以256就是采集到的水温
  MUL AB	 
  MOV R7,B	     ;乘积的高八位会进入B，低八位进入A，这个数除以256，相当于这个数往右边移动八位，所以B就是水的温度值
  MOV A,R7	     ;分离水温的前后四位（现在的水温是十六进制的，后四位的值不会超过15）
  MOV B,#0AH  
  DIV AB	   
  MOV 31H,A		 ;十位放到数码管2
  MOV 30H,B		 ;个位放到数码管1
  RET			 ;子程序返回



INTT1:
  CLR EX1
  MOV PROTECTION,A  ;保存原来的累加器
  MOV DPTR,#0DFFAH	;读转换值
  MOVX A,@DPTR		;读转换值
  MOV R3,A			; 寄存转换值
  MOVX @DPTR,A		;启动AD转换
  MOV A,PROTECTION	;恢复
  SETB EX1
  RETI				;返回断点

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