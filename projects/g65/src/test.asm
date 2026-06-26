	.include "stddefs.inc"

reset_isr:

	;jsr test_parser_cmd_line
	;jsr test_convert_functions
	jsr test_memory_functions

halt: 
	jmp halt

test_memory_functions:
	; test strcmp
	lda #<test_text
	sta R6
	lda #>test_text
	sta R7
	lda #<test_text2
	sta R4
	lda #>test_text2
	sta R5
	jsr strcmp
.halt:
	bra .halt

	; test memset
	; destination address
	lda #$15
	sta R7
	lda #$00
	sta R6
	; value 
	lda #$aa
	sta R5
	; count of bytes to set
	lda #$10
	sta R3
	lda #$00
	sta R2

	jsr memset	

	; test memcpy
	
	; source address
	lda #$15
	sta R7
	lda #$00
	sta R6

	; destination address
	lda #$30
	sta R5
	lda #$00
	sta R4

	; count of bytes to copy
	lda #$10
	sta R3
	lda #$00
	sta R2
	
	jsr memcpy

	; test memcmp

	; source address
	lda #$15
	sta R7
	lda #$00
	sta R6

	; destination address
	lda #$30
	sta R5
	lda #$00
	sta R4

	; count of bytes to copy
	lda #$10
	sta R3
	lda #$00
	sta R2

	jsr memcmp

	;jsr $ff18				; print_hex_byte

	;jmp $fffc				; go back to monitor

	rts

test_convert_functions:
	lda #<test_address
	sta R6
	lda #>test_address
	sta R7

	jsr ahex2byte
	sta R0

	inc R6
	inc R6
	jsr ahex2byte
	sta R1

	rts


read_hex_byte:
	lsr a
	lsr a
	lsr a
	lsr a
	jsr ahex2nib

	rts

read_hex_word:
	; read first hex char from command line
	; convert to binary
	; save to 
	; read second hex char from command line

	rts


test_parser_cmd_line:
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
	bcc .exit

	lda #<address
	sta R6
	lda #>address
	sta R7
	jsr parser_cmd_line_next_token
	bcc .exit
	
	lda #<address2
	sta R6
	lda #>address2
	sta R7
	jsr parser_cmd_line_next_token
	bcc .exit

	lda #<address3
	sta R6
	lda #>address3
	sta R7
	jsr parser_cmd_line_next_token
	bcc .exit

	jsr parser_cmd_line_next_token
	bcc .exit
.exit:
	rts



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
test_command:	.asciiz "       peek     a1b2     00fd            1234   "
test_address:	.db '9', '6', '3', '0'
test_text:		.asciiz ""		;"The little brown fox jumps over the lazy dog."
test_text2:		.asciiz "The little brow fox jumps over the lazy dog."

	.section .bss
command:	.ds 256
address:	.ds 4
address2:	.ds 4
address3:	.ds 4

