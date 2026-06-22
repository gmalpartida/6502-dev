	.include "interrupts.inc"

	.section .text

nmi_isr:

	rts

	.section .vectors
		.word	nmi_isr			; nmi vector
		.word	reset_isr		;points to start of code
		.word	uart_rx_isr			; irq vector
