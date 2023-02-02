decompress	.EQU	0A000H		;Old Stack Location 
rows        .EQU	32
cols        .EQU	32/4

CR          .EQU     0DH
LF          .EQU     0AH

printImage:
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
    LD      B, D                ;Are we at the end of the file
    DJNZ    saveRowPos          ;if not, pesist D
    RET                         ;EXIT 

saveRowPos:
    LD      D,B                 ;Persist the new D
    JR      mainLoop

saveColPos:
    LD      E,B                 ;Persist the new E
    JR      mainLoop           

printByte:
    LD      C, (HL)             ;Load in the data into C for safe keeping
    LD      A, C                ;Move it into A so we can work on it
    LD      B, 3                ;Setup the loop to pogress through the byte
bytePrintLoop:
    PUSH    BC                  ;Save the position of the byte progress loop to the stack
printIChar:                     ;prints the char indexed in A
    AND		00000011b           ;Mask off the lower bits
    LD      DE, chars           ;Get the adress of the printout chars
    JR      Z, endScan          ;If we have a zero, go straight to print
    LD      B,  A               ;If not setup a loop
scanChars:
    INC     DE                  ;For the size of A, increment through the char array (moving into lighter chars)
    DJNZ    scanChars 
endScan:
    LD      A, (DE)
    RST     08H                 ;print out the char
    RST     08H
    POP     BC                  ;Retrive the position of the byte progress loop to the stack
    LD      A,C                 ;Get back a clean copy of the data
    RR      A                   ;Move to the next nibble
    RR      A
    LD      C,A                 ;Persist the shifted byte into C
    DJNZ    bytePrintLoop       ;Are we at the end of the byte
    JR      printReturn
    
    include 'compress.asm'
image:
    incbin "image.bin"
chars:    .BYTE   " :*@"
