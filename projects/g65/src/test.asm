	.include "stddefs.inc"

reset_isr:

	jsr parser_cmd_line_init

	lda #<test_command
	sta R6
	lda #>test_command
	sta R7
	lda #$30
	sta R2
	lda #$00
	sta R3
	jsr parser_cmd_line_set_test_command

	lda #<command
	sta R6
	lda #>command
	sta R7
	jsr parser_cmd_line_next_token
	bcc halt

	lda #<address
	sta R6
	lda #>address
	sta R7
	jsr parser_cmd_line_next_token
	bcc halt
	
	lda #<address2
	sta R6
	lda #>address2
	sta R7
	jsr parser_cmd_line_next_token
	bcc halt

	lda #<address3
	sta R6
	lda #>address3
	sta R7
	jsr parser_cmd_line_next_token
	bcc halt

	jsr parser_cmd_line_next_token
	bcc halt

halt:
	jmp halt



;==============================================================================================================
irq_isr:
	rti

nmi_isr:
    rti             			; Return from Non-Maskable Interrupt

	.section .vectors
		.word	nmi_isr			; nmi vector
		.word	reset_isr		;points to start of code
		.word	irq_isr			; irq vector

;==============================================================================================================

	.section .rodata
test_command: .asciiz "       peek     a1b2     00fd            1234   "

	.section .bss
command:	.ds 256
address:	.ds 4
address2:	.ds 4
address3:	.ds 4

