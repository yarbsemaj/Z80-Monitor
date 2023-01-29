waitcolon:
            rst 10H         ; wait for Rx ':'
            cp ':'
            jr NZ,waitcolon
hexFromMon: ld c,0          ; reset C to compute checksum
            call readbyte   ; read byte count
            ld b,a          ; store it in B
            call readbyte   ; read upper byte of address
            ld d,a          ; store in D
            call readbyte   ; read lower byte of address
            ld e,a          ; store in E
            call readbyte   ; read record type
            cp 01           ; check if record type is 01 (end of file)
            jr Z,endload
            cp 00           ; check if record type is 00 (data)
            jr NZ,invtype   ; if not, error

readdata:
            call readbyte
            ld (de),a
            inc de
            djnz readdata   ; if not, loop

            call readbyte   ; read checksum
            ld a,c          ; C should be 0
            or a
            jr NZ,badck

            ld a,'#'        ; "#" per line loaded
            rst 08H          ; Tx byte
            jr waitcolon

endload:
            call readbyte   ; read last checksum (not used)
            ld a,c          ; C checksum should be 0
            or a
            jr NZ,badck     ; non zero, we have an issue
            ld hl,loadokstr
            call rPrint
            jp CI			; Return to monitor

invtype:
            ld hl,invalidtypestr
            call rPrint
            ret

badck:
            ld hl,badchecksumstr
            call rPrint
            ret

readbyte:                   ; Returns byte in A, checksum in C
            call readnibble ; read the first nibble
            rlca            ; shift it left by 4 bits
            rlca
            rlca
            rlca
            ld l,a          ; temporarily store the first nibble in L
            call readnibble ; get the second (low) nibble
            or l            ; assemble two nibbles into one byte in A
            ld l,a          ; put assembled byte back into L
            add a,c         ; add the byte read to C (for checksum)
            ld c,a
            ld a,l
            ret             ; return the byte read in A (L = char received too)  

readnibble:
            rst 10H         ; Rx byte
            sub '0'
            cp 10
            ret C           ; if A<10 just return
            sub 7           ; else subtract 'A'-'0' (17) and add 10
            ret
			
.END
