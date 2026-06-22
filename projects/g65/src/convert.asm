	.include "convert.inc"

	.section .text

ahex2byte:
	ldy #$00
	lda (R6), y
	jsr ahex2nib
	asl
	asl
	asl
	asl
	sta R5

	iny
	lda (R6), y
	jsr ahex2nib
	ora R5
	rts

ahex2nib:
    cmp #$61
    bcc .upper
    sec
    sbc #$20
.upper:
    sec
    sbc #$30
    cmp #$0A
    bcc .exit
    sec
    sbc #$07
.exit:
    rts

byte2ahex:
    pha                 ; Save original byte to stack
    
    ; Process Upper Nibble
    lsr a
    lsr a
    lsr a
    lsr a               ; Move upper 4 bits to lower 4 bits
    jsr nib2ahex        ; Convert to ASCII
    sta R7              ; Keep upper ASCII character in R7
    
    ; Process Lower Nibble
    pla                 ; Pull original byte back from stack
    and #$0f            ; Mask out upper nibble, keep lower 4 bits
    jsr nib2ahex        ; Convert to ASCII (leaves result in A)
    sta R6
    rts

nib2ahex:
    cmp #$0a
    bcc .is_num
    clc
    adc #$07
.is_num:
    clc
    adc #$30
    rts


