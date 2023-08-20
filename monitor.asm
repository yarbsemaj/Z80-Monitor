CR              .EQU    0DH
LF              .EQU    0AH
BytesPerLine	.EQU	08H

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
				JR		READCOMMAND
; Input reading
; ------------------------------------------------------------------
rCmd:
				RST     08H
				LD		A, ' '
				RST     08H
				CALL 	READBYTEM ; Read Start Byte
				LD		H, A
				CALL 	READBYTEM
				LD		L, A
				LD		A, '.'
				RST     08H
				CALL 	READBYTEM  ; Read End Byte
				LD		D, A
				CALL 	READBYTEM
				LD		E, A
				INC 	DE			;Increment end byte for zero compear
				LD		B, 0H		; B is used for line position
				CALL	NEWLINE
				CALL	LINESTART
				PUSH	HL
				JP		PRINTMEM
				JR		CI


READBYTEM:							; Reads a byte in hex from the console
				call 	READNIBBLEM
         		call 	Hex1M
         		add  	a,a
         		add  	a,a
         		add  	a,a
         		add  	a,a
				PUSH	DE
         		ld   	d,a
         		call 	READNIBBLEM
         		call 	Hex1M
         		or   	d
				POP		DE
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
writeLoop:
				LD		A, ' '
				RST     08H
				CALL	READBYTEM
				LD		(HL),A
				INC		HL
				JR		writeLoop
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
				;RET    Program Should Return
				

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
				
PRINTMEM:
				LD		A, B
				CP 		BytesPerLine
				JR    	NZ, NEXTMEMCHAR
				POP		HL
				CALL	ENDLINE
				PUSH    HL
				LD		B, 0
NEXTMEMCHAR:	LD		A, ' '
				RST     08H
				LD		A,(HL)
				CALL	NumToHex
				INC		HL
				PUSH	HL
				OR 		A					; Clear Carry Flag for SUBC
				SBC		HL,DE
				POP		HL
				JR		Z,ENDMEMPRINT		; JP on end
				INC		B
				JR		PRINTMEM			; JP NEXT CHAR
ENDMEMPRINT:
				POP		HL
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
				LD		A, ' '
				RST     08H
				RET
ENDBLOCK:
				LD		B,2					;2 Spaces
				CALL	printSpacing
				LD		B, 0

PRINTASCICHAR:	
				INC		B			
				LD		A, (HL)
				CP		32				;Exclude unprintable chars
				JR		C,NONPRINTABLE
				CP		127				;Exclude unprintable chars
				JR		NC,NONPRINTABLE
				LD		A, (HL)
				JR		PRINTCHAR
				
NONPRINTABLE:
				LD		A, '.'
PRINTCHAR:		
				RST     08H
				INC		HL


				PUSH	HL
				OR 		A					; Clear Carry Flag for SUBC
				SBC		HL,DE
				POP		HL
				JR    	Z, FINISHPRINTCHAR	; JP on end


				LD		A, B
				CP 		BytesPerLine
				JR    	NZ, PRINTASCICHAR

FINISHPRINTCHAR:
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
				POP		HL
				JP		CI

printSpacing:
				LD 		A, ' '
				RST     08H
				DJNZ	printSpacing
				RET
				
signOnMon:		.BYTE	"JB Monitor v4.0",LF,CR,0