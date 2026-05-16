	.section .text

reset_isr:
    sei             ; Disable interrupts
    cld             ; Clear decimal mode
    ldx #$ff        ; Initialize stack pointer to $01ff
    txs

nmi_isr:
    rti             ; Return from Non-Maskable Interrupt

irq_isr:
    rti             ; Return from Maskable Interrupt / BRK

	.section .rodata
little_brown_fox_txt: .asciiz "The quick brown fox jumps over the lazy dog."

	.section .vectors
	.word	nmi_isr		; nmi vector
	.word	reset_isr	;points to start of code
	.word	irq_isr		; irq vector

