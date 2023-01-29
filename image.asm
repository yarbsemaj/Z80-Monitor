decompress	.EQU	0A000H		;Old Stack Location 
rows        .EQU	32
cols        .EQU	32/4

CR          .EQU     0DH
LF          .EQU     0AH
printEE:
	ld		HL, image           ;Load and Decompress the image
    ld		DE,decompress
    call    dzx0_standard

    LD      D, rows             ;Number of ROWS
    LD      E, cols             ;Number of COLS

    LD      HL,decompress       ;Start HL
mainLoop: 
    PUSH    DE                  ;Store awy for later
    JR      printByte           ;Print the a byte
printReturn:
    INC     HL                  ;Get the next byte
    POP     DE                  ;GET DE Back
    LD      B,E                 ;GET Cols
    DJNZ    saveColPos          ;Are we at the end of a row?
    LD      E, cols             ;Reset Col Position
    LD      A, CR               ;New Line
    RST     08H
    LD      A, LF
    RST     08H
    LD      B, D
    DJNZ    saveRowPos
    RET

saveRowPos:
    LD      D,B
    JR      mainLoop

saveColPos:
    LD      E,B
    JR      mainLoop           

printByte:
    LD      C, (HL)             ;Load in the data
    LD      A, C                ;Take the upper byte
    CALL    printImageChar      ;Print the char of the byte 1
    LD      A,C                 
    RR      A                   ;Move to the next nibble
    RR      A
    LD      C,A
    CALL    printImageChar      ;Print the char of the byte 2
    LD      A,C                 
    RR      A                   ;Move to the next nibble
    RR      A
    LD      C,A
    CALL    printImageChar           ;Print the char of the byte 3
    LD      A,C                 
    RR      A                   ;Move to the next nibble
    RR      A
    LD      C,A
    CALL    printImageChar      ;Print the char of the byte 4
    JR      printReturn

printImageChar:                 ;prints the char indexed in A
    AND		00000011b           ;Mask off the lower bits
    LD      DE, chars           ;Get the adress of the printout chars
    CP      00H
    JR      Z, endScan          ;If we have a zero, go styright to print
    LD      B,  A               ;If not setup a loop
    LD      (05000H),A
scanChars:
    INC     DE
    DJNZ    scanChars 
endScan:
    LD      A, (DE)
    RST     08H ;print out the char
    RST     08H ;print out the char
    RET
    
    include 'compress.asm'
image:
    incbin "imagesmaller.bin"
chars:    .BYTE   " :*@"
