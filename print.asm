rPrint:
            ld a,(hl)
            or a
            ret Z

            rst 08H          ; Tx byte
            inc hl
            jr rPrint