	.include "vt102.inc"

VT102_ESC			= $1b

	.section .text

vt102_clrscrn:
	lda #<VT102_CLEAR_SCREEN
	sta R6
	lda #>VT102_CLEAR_SCREEN
	sta R7
	jsr uart_tx_asciiz

	rts


	.section .rodata
VT102_UP:           .db			VT102_ESC, '[', 'A', 0
VT102_DOWN:         .db			VT102_ESC, '[', 'B', 0
VT102_RIGHT:        .db			VT102_ESC, '[', 'C', 0
VT102_LEFT:         .db			VT102_ESC, '[', 'D', 0
VT102_CLEAR_SCREEN: .asciiz		VT102_ESC, '[', 'H', VT102_ESC, '[', '2', 'J'
