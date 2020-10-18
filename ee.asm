			LD		HL,eeMSG
ePrint:
            ld a,(hl)
            or a
            ret Z
			xor	0FFH
            rst 08H          ; Tx byte
            inc hl
            jr ePrint
			
eeMSG:      .BYTE $ac,$8e,$8a,$96,$9b,$98,$9a,$df,$c3,$cc,0