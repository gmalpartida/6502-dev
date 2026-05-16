    .section .zp

	.global R0
	.global R1
	.global R2
	.global R3
	.global R4
	.global R5
	.global R6
	.global R7
	.global R0L
	.global R0H
	.global R2L
	.global R2H
	.global R4L
	.global R4H

; Zero Page Register File (example starts at $00)
R0  .ds $01
R1	.ds $01
R2	.ds $01
R3	.ds $01
R4	.ds $01
R5	.ds $01
R6	.ds $01
R7	.ds $01

; 16-bit Pointer Aliases
R0L  = R0
R0H  = R1
R2L  = R2
R2H  = R3
R4L  = R4
R4H  = R5

