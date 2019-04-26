			  PROTECTION EQU 3AH

			  ORG 0000H
			  LJMP BEGIN
			  ORG 0013H	     ;Íâ²¿ÖÐ¶Ï1µÄÈë¿Ú
			  LJMP INTT1	 ;µ÷µ½Íâ²¿ÖÐ¶Ï
			  ORG 0060H	


BEGIN:
			  	SETB EA	    ;×ÜÖÐ¶Ï¿ª¹Ø´ò¿ª
			 	SETB EX1	    ;Íâ²¿ÖÐ¶Ï1ÔÊÐíÆôÓÃ
			 	SETB IT1	    ;¿ªÆôÍâÖÐ¶Ï1,¼ì²é¶Ë¿ÚÊÇ·ñÓÐÖÐ¶ÏÐÅºÅ
			 	MOV SP,#70H	;¶ÑÕ»Ö¸ÕëÉèÖÃ
			 	MOV DPTR,#0DFFAH ;Æô¶¯AD×ª»»£¬Ö®ºóµÈ´ýADÄ£¿é×ª»»½áÊø£¬·¢³öÖÐ¶ÏÇëÇó
			 	MOVX @DPTR,A	   ;Æô¶¯AD×ª»»£¬Ö®ºóµÈ´ýADÄ£¿é×ª»»½áÊø£¬·¢³öÖÐ¶ÏÇëÇó
			 	CLR P1.6
MAIN: 

LOOP: 			LCALL BCD         ;ÏÔÊ¾Éè¶¨Öµ£¬Í¬Ê±½«Éè¶¨Öµ×ªÎªÊ®Áù½øÖÆ´æÔÚR2ÖÐ
			 	LCALL TEMTRANS    ;²É¼¯Êý¾ÝµÄÊ®Áù½øÖÆ×ª»»
			  	LCALL DISPLAY     ;ÏÔÊ¾³ÌÐò

				SJMP LOOP
				

				RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INTT1:
			  CLR EX1
			  MOV PROTECTION,A  ;±£´æÔ­À´µÄÀÛ¼ÓÆ÷
			  MOV DPTR,#0DFFAH	;¶Á×ª»»Öµ
			  MOVX A,@DPTR		;¶Á×ª»»Öµ
			  MOV R3,A			;¶ÁÊý´¢´æÖÁR3
			  MOVX @DPTR,A		;Æô¶¯AD×ª»»
			  MOV A,PROTECTION	;»Ö¸´
			  SETB EX1
			  RETI				;·µ»Ø¶Ïµã
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BCD:
			  CLR P1.7		   ;Ñ¡Ôñ²¦ÂëÅÌÇ°Á½Î»
			  MOV DPTR,#0BFFFH
			  MOVX A,@DPTR	   ;¶Á³ö²¦ÂëÅÌ8Î»¶þ½øÖÆÊý
			  CPL A			   ;È¡·´

			  ; MOV R2,A

			  MOV B,#10H	   ;·ÖÀëÇ°ËÄÎ»ºÍºóËÄÎ»
			  DIV AB		   ;·ÖÀëÇ°ËÄÎ»ºÍºóËÄÎ»
			  MOV 32H,B		   ;Éè¶¨ÎÂ¶ÈÖµµÃ¸öÎ»´æÈëÊýÂë¹Ü3
			  MOV 33H,A		   ;Éè¶¨ÎÂ¶ÈÖµµÃÊ®Î»´æÈëÊýÂë¹Ü4


			  MOV B,#0AH	   ;¸³ÓèBÎª10
			  MUL AB		   ;Ê®Î»Êý³Ë10µÃµ½ÆäÊ®Áù½øÖÆ±í´ï
			  ADD A,32H		   ;¼ÓÉÏ¸öÎ»Êý
			  MOV R2,A		   ;Éè¶¨Öµ³É¼´×ª»»ÎªÊ®Áù½øÖÆ


			RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TEMTRANS:		 ;²É¼¯µ½ÎÂ¶ÈÖµµÄÊ®½øÖÆ×ª»»
			  MOV A,R3	  
			  MOV B,#100     ;²É¼¯µ½µÄ8Î»¶þ½øÖÆÊýÏÈ³ËÒÔ100£¬ÔÙ³ýÒÔ256¾ÍÊÇ²É¼¯µ½µÄË®ÎÂ
			  MUL AB	 
			  MOV R7,B	     ;³Ë»ýµÄ¸ß°ËÎ»»á½øÈëB£¬µÍ°ËÎ»½øÈëA£¬Õâ¸öÊý³ýÒÔ256£¬Ïàµ±ÓÚÕâ¸öÊýÍùÓÒ±ßÒÆ¶¯°ËÎ»£¬ËùÒÔB¾ÍÊÇË®µÄÎÂ¶ÈÖµ
			  MOV A,R7	     ;·ÖÀëË®ÎÂµÄÇ°ºóËÄÎ»£¨ÏÖÔÚµÄË®ÎÂÊÇÊ®Áù½øÖÆµÄ£¬ºóËÄÎ»µÄÖµ²»»á³¬¹ý15£©
			  MOV B,#0AH  
			  DIV AB	   
			  MOV 31H,A		 ;Ê®Î»·Åµ½ÊýÂë¹Ü2
			  MOV 30H,B		 ;¸öÎ»·Åµ½ÊýÂë¹Ü1
			  RET			 ;×Ó³ÌÐò·µØ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY:	   ;ÏÔÊ¾º¯Êý
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
DSEG1:				  ;¶ÎÂë±í
				DB 0C0H,0F9H,0A4H,0B0H
				DB 99H,92H,82H,0F8H
				DB 80H,90H,88H,83H
				DB 0C6H,0A1H,86H,8EH
				  
				  END