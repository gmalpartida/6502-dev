	.include "string.inc"

	.section .text

; copies a byte value to the first n locations of a buffer
; --> R7, R6: address of buffer
; --> R5:     byte value to copy
; --> R3, R2: count of bytes to set
; <-- none
memset:
    ldy #0
.loop:
	lda R5
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

; copies n bytes from a source buffer to a destination buffer
; --> R7, R6: address of source buffer       (R7=High, R6=Low)
; --> R5, R4: address of destination buffer  (R5=High, R4=Low)
; --> R3, R2: count of bytes to copy         (R3=High, R2=Low)
; <-- none
memcpy:
    ldy #0
.loop:
	lda R2				; exit if count is zero
	ora R3
	beq .exit
    lda (R6), y         ; Read byte from source buffer
    sta (R4), y         ; Write byte to destination buffer
    ldx R2
    bne .skip_dec_hi    ; If low count isn't zero, skip high decrement
    dec R3              ; Decrement high count
.skip_dec_hi:
    dec R2              ; Decrement low count
.next_char:
    iny
    bne .loop           ; Continue loop if page boundary not hit
    inc R7              ; Source page rolled over
    inc R5              ; Destination page rolled over
    bra .loop
.exit:
    rts

; compares n bytes of two memory buffers
; --> R7, R6: address of buffer 1            (R7=High, R6=Low)
; --> R5, R4: address of buffer 2            (R5=High, R4=Low)
; --> R3, R2: count of bytes to compare      (R3=High, R2=Low)
; <-- A:      result (0 = equal, 1 = B1 > B2, $FF = B1 < B2)
memcmp:
    ldy #0
.loop:
	lda R2
	ora R3
	beq .equal_exit

    lda (R6), y         ; Fetch byte from Buffer 1
    cmp (R4), y         ; Compare with Buffer 2
    bne .mismatch       ; Bytes don't match! Jump straight to evaluation
    ldx R2
    bne .skip_dec_hi
    dec R3
.skip_dec_hi:
    dec R2
.next_char:
    iny
    bne .loop
    inc R7              ; Buffer 1 page rolled over
    inc R5              ; Buffer 2 page rolled over
    bra .loop

.mismatch:
    bcc .less_than      ; If Carry flag is clear, Buffer 1 < Buffer 2
    lda #$01            ; Buffer 1 is greater
	sec
    rts
.less_than:
    lda #$ff            ; Buffer 1 is less
	sec
    rts

.equal_exit:
	clc
    lda #0              ; Clean match found
    rts

; compares two null-terminated strings.
; preserves the pointers
; -->	R7:R6		pointer of first string
; -->	R5:R4		pointer of second string
; <--	C			set if matched, otherwise clear
strcmp:
	lda R7
	pha
	lda R6
	pha
	lda R5
	pha
	lda R4
	pha
	ldy #$00
.loop:
	lda (R6), y
	sta R3
	lda (R4), y
	ora R3
	beq .match
	lda (R4), y
	cmp R3
	bne .mismatch
	inc R4
	bne .cont
	inc R5
.cont:
	inc R6
	bne .cont2
	inc R7
.cont2:
	bra .loop
.mismatch:
	clc
	bra .exit
.match:
	sec
.exit:
	pla
	sta R4
	pla
	sta R5
	pla
	sta R6
	pla
	sta R7
	rts

