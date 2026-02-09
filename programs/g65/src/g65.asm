	.include "stddefs.inc"
	.section .text

reset_isr:
    sei             			; Disable interrupts
    cld             			; Clear decimal mode
    ldx #$ff        			; Initialize stack pointer to $01ff
    txs

	jsr init_regs				; initialize all registers to 00

test_memset:
	lda #$00					; destination buffer
	sta R0L
	lda #$02
	sta R0H
	
	lda #$ff					; character to copy
	sta R2

	lda #$00					; count of bytes to copy
	sta R4L
	lda #$06
	sta R4H

	jsr memset

	ldx #$2
test_memcpy:
	
	; load source adddress
	lda #<little_brown_fox_txt
	sta R0L
	lda #>little_brown_fox_txt
	sta R0H

	; load destination address
	lda #$00
	sta R2L
	txa
	sta R2H

	; load count of bytes to copy
	lda #$2C
	sta R4L
	lda #$00
	sta R4H
	stx R2H

	jsr memcpy
	inx
	cpx #8
	bne test_memcpy
        
	ldx #$02
test_memcmp:

	; load source adddress
	lda #<little_brown_fox_txt
	sta R0L
	lda #>little_brown_fox_txt
	sta R0H

	; load destination address
	lda #$00
	sta R2L
	txa
	sta R2H

	; load count of bytes to copy
	lda #$2C
	sta R4L
	lda #$00
	sta R4H
	stx R2H

	jsr memcmp
	cmp #$00
	bmi halt
	bpl halt

	inx
	cpx #8
	bne test_memcmp

halt:   
	jmp halt          				; End of program

init_regs:
	lda #$00
	sta R0
	sta R1
	sta R2
	sta R3
	sta R4
	sta R5
	sta R6
	sta R7
	
	rts

nmi_isr:
    rti             				; Return from Non-Maskable Interrupt

irq_isr:
    rti             				; Return from Maskable Interrupt / BRK

	.section .rodata
		little_brown_fox_txt: .asciiz "The quick brown fox jumps over the lazy dog."

	.section .vectors
		.word	nmi_isr				; nmi vector
		.word	reset_isr			;points to start of code
		.word	irq_isr				; irq vector

