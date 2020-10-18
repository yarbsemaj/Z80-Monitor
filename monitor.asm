CR              .EQU    0DH
LF              .EQU    0AH
BytesPerLine	.EQU	10H

StartMon:
				LD		HL,signOnMon
				CALL	rPrint
CI:
				CALL 	NEWLINE
				LD		A, '>'
				RST     08H
READCOMMAND:				
				RST     10H
				CP      ':'
				JP    	Z, hexFromMon
				AND     11011111b       ; lower to uppercase
				CP      'R'
				JR      Z, rCmd
				CP      'W'
				JR      Z, WRITE
				CP      'E'
				JR    	Z, EXICUTE
				CP      'H'
				JR      Z, HELP
				JR		READCOMMAND
; Input reading
; ------------------------------------------------------------------
rCmd:
				RST     08H
				LD		A, ' '
				RST     08H
				CALL 	READBYTEM
				LD		H, A		; fill with 00 for now
				LD		L, 0H
				PUSH 	HL
				LD		B, 0H		; B is used for line position
				CALL 	NEWLINE
				CALL	memHeader
				CALL 	NEWLINE
				CALL 	NEWLINE
				LD		B, 0H		; B is used for line position
				POP		HL
				CALL	LINESTART
				JP		PRINTMEM
				JR		CI


READBYTEM:							; Reads a byte in hex from the console
				call 	READNIBBLEM
         		call 	Hex1M
         		add  	a,a
         		add  	a,a
         		add  	a,a
         		add  	a,a
         		ld   	d,a
         		call 	READNIBBLEM
         		call 	Hex1M
         		or   	d
         		ret

READNIBBLEM:
				RST     10H
				LD		B,A
				JP		CHECKVALID
CHARVALID:
				LD		A,B
				RST     08H
				RET

Hex1M:     		
				sub  '0'
         		cp   10
         		ret  c
         		sub  'A'-'0'-10
         		ret

WRITE:
				RST     08H
				LD		A, ' '
				RST     08H
				CALL	READBYTEM
				LD		H,A			;Coppy first address byte
				CALL	READBYTEM
				LD		L,A			;Coppy second address byte
				LD		A, ' '
				RST     08H
				CALL	READBYTEM
				LD		(HL),A
				JP		CI
EXICUTE:
				RST     08H
				LD		A, ' '
				RST     08H
				CALL	READBYTEM
				LD		H,A			;Coppy first address byte
				CALL	READBYTEM
				LD		L,A			;Coppy second address byte
				CALL	NEWLINE
				CALL	EXICUTEPROGRAM
				JP		CI
EXICUTEPROGRAM:				
				JP 		(HL)
				RET
				
HELP:
				RST     08H
				CALL	NEWLINE
				LD		HL,helpMSG
				CALL	rPrint
				JP		CI

NumToHex    	ld 		c, a   		; a = number to convert
            	call 	Num1
            	RST     08H
            	ld 		a, c
            	call 	Num2
            	RST     08H
            	ret

Num1        	rra
            	rra
            	rra
           		rra
Num2        	or 		$F0
            	daa
            	add 	a, $A0
            	adc 	a, $40 		; Ascii hex at this point (0 to F)   
            	ret

memHeader:
				LD		HL, hPadding
				CALL	rPrint
memHeaderLoop:	LD		A, B
				CP 		BytesPerLine
				RET    	Z
				CALL	NumToHex
				LD		A, ' '
				RST     08H
				INC		B
				JR		memHeaderLoop
				
PRINTMEM:
				LD		A, B
				CP 		BytesPerLine
				CALL    Z, ENDLINE
				LD		A, ' '
				RST     08H
				LD		A,(HL)
				CALL	NumToHex
				INC		L
				LD		A, L
				CP		$00
				JR		Z,ENDMEMPRINT		; JP on 255
				INC		B
				JR		PRINTMEM			; JP NEXT CHAR
ENDMEMPRINT:
				CALL	ENDBLOCK
				JP		CI			

ENDLINE:
				CALL	ENDBLOCK
				CALL	LINESTART
				RET
LINESTART:		
				LD		A, H
				CALL	NumToHex
				LD		A, L
				CALL	NumToHex
				PUSH	HL
				LD		HL, sPadding
				CALL	rPrint
				POP		HL
				RET
ENDBLOCK:
				PUSH	HL
				LD		HL, lPadding
				CALL	rPrint
				POP		HL
				LD		A,L					;Start printing line again, this time in asci
				LD 		B, 0H
				SUB 	BytesPerLine
				LD		L, A
PRINTASCICHAR:	
				INC		B			
				LD		A, (HL)
				AND		11100000b			;Exclude unprintable chars
				JR		Z,NONPRINTABLE
				LD		A, (HL)
				JR		PRINTCHAR
				
NONPRINTABLE:
				LD		A, '.'
PRINTCHAR:		
				RST     08H
				INC		L
				LD		A, B
				CP 		BytesPerLine
				JR    	NZ, PRINTASCICHAR
				LD 		B, 0H
				CALL	NEWLINE
				RET

NEWLINE:
				PUSH 	AF
				LD		A, CR
				RST     08H
				LD		A, LF
				RST     08H
				POP		AF
				RET

CHECKVALID:    
				LD		A,B
				CP		03h				;Control C
				JR		Z, clearCom
				SUB		'0'
				JP		M,READNIBBLEM
				SUB		$A				; Subtract 10
				JP		M,CHARVALID
				LD		A,B
				AND     11011111b       ; lower to uppercase
				LD		B,A
				SUB		'A'
				JP		M,READNIBBLEM
				SUB		$6				; Subtract 10
				JP		M,CHARVALID
				JP		READNIBBLEM
clearCom:
				POP		HL
				JP		CI
				
signOnMon:		.BYTE	"JB MON V2",LF,CR
				.BYTE	"H for Help",0
helpMSG:		.BYTE	"R nn - Read FF bytes from nn00",LF,CR
				.BYTE	"W nnnn xx - Write byte xx to nnnn",LF,CR
				.BYTE	"E nnnn	- Run nnnn",LF,CR
				.BYTE	"E 0100/3 - Basic C/W",LF,CR
				.BYTE	"Send ihex to load",0
hPadding		.BYTE	"   "
lPadding		.BYTE	"  "
sPadding		.BYTE	"  ",0