	.include "string.inc"

	.section .text

; copies a byte value to the first n locations of a buffer
; --> R7, R6: address of buffer
; --> R5:	  byte value to copy
; --> R3, R2: count of bytes to set
; <-- none
memset:
    ldy #0
    lda R5
.loop:
    sta (R6), y
    ldx R2
    bne .skip_dec_hi
    dec R3
.skip_dec_hi:
    dec R2
    ldx R2
    bne .next_char
    ldx R3
    beq .exit
.next_char:
    iny
    bne .loop
    inc R7
    bra .loop
.exit:
    rts

; compares the first n bytes of two buffers
; --> R7, R6: address of first buffer
; --> R5, R4: address of second buffer
; --> R3, R2: count of bytes to compare
; <-- Carry = 0 if equal, otherwise Carry = 1
memcmp:
	ldy #0
.next_byte:
	lda R3
	ora R2
	beq .equal						; if count = 0 then nothing to do
	; Compare one byte
	lda (R6), y
	cmp (R4), y
	bne .not_equal
	inc R6
	bne .skip1
	inc R7
.skip1:
	inc R4
	bne .skip2
	inc R5
.skip2:
	lda R2
	bne .skip3
	lda R3
.skip3:
	dec R2
	jmp .next_byte
.not_equal:
	sec
	rts
.equal:
	clc
    rts

; copies the first n bytes from source buffer to destination buffer
; R7:R6			address of source buffer
; R5:R4			address of destination buffer
; R3:R2			how many bytes to copy
memcpy:
    ldy #0
.loop:
    ldx R2
    bne .continue
    ldx R3
    beq .exit
.continue:
    lda (R6), y
    sta (R4), y
    ldx R2
    bne .skip_dec_hi
    dec R3
.skip_dec_hi:
    dec R2
    iny
    bne .loop
    inc R7
    inc R5
    bra .loop
.exit:
    rts

